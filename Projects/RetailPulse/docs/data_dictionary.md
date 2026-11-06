# RetailPulse data dictionary

The SQL schema is the authoritative source for exact column types and constraints. All identifiers are surrogate numeric keys except the composite order-item key. Money uses fixed-point `DECIMAL` values representing INR. Treat the synthetic `DATETIME` values as UTC; the type itself does not store a timezone.

## Tables and grains

| Table | One row represents | Primary key | Relationships |
| --- | --- | --- | --- |
| `customers` | A registered customer | `customer_id` | Parent of orders |
| `categories` | A product category | `category_id` | Parent of products |
| `products` | A catalog product and its current stock | `product_id` | Category; parent of order items and inventory movements |
| `orders` | An order header | `order_id` | Customer; parent of lines, payments, refunds, and optional stock movements |
| `order_items` | One product within one order | `(order_id, product_id)` | Order and product |
| `payments` | A payment attempt | `payment_id` | Order; several attempts may belong to an order |
| `refunds` | An order-level refund event | `refund_id` | Order; several refund events may belong to an order |
| `inventory_movements` | A signed stock change or opening snapshot | `movement_id` | Product and optional order |

## Column meanings

### `customers`

| Column | Meaning |
| --- | --- |
| `customer_id` | Customer identifier |
| `full_name` | Fictional customer name |
| `email` | Unique fictional email address |
| `city` | Customer city for segmentation |
| `signup_date` | Date the customer registered |

### `categories`

| Column | Meaning |
| --- | --- |
| `category_id` | Category identifier |
| `name` | Category name |

### `products`

| Column | Meaning |
| --- | --- |
| `product_id` | Product identifier |
| `category_id` | Parent category |
| `sku` | Unique stock-keeping code |
| `name` | Product display name |
| `unit_price` | Current catalog selling price; does not replace historical order-line prices |
| `unit_cost` | Current catalog cost; does not replace historical order-line costs |
| `stock_quantity` | Current available units; reduced when a reservation succeeds |

### `orders`

| Column | Meaning |
| --- | --- |
| `order_id` | Order identifier |
| `customer_id` | Purchasing customer |
| `ordered_at` | Order timestamp and reporting attribution date |
| `status` | `pending`, `paid`, `shipped`, `completed`, or `cancelled` |
| `channel` | `web`, `mobile`, or `marketplace` |

Sales reports include `paid`, `shipped`, and `completed` orders only. Pending reservations have no recognized sales in these reports; cancelled orders are excluded. Status is a simplified demo lifecycle, not a complete payment or fulfillment event history.

### `order_items`

| Column | Meaning |
| --- | --- |
| `order_id` | Parent order |
| `product_id` | Purchased product; appears at most once in an order |
| `quantity` | Number of units on the line |
| `unit_price` | Historical selling price per unit |
| `unit_cost` | Historical cost per unit |
| `discount_amount` | Total currency discount for the whole line, capped at its gross value |

Line gross sales = `quantity * unit_price`. Line net sales = `quantity * unit_price - discount_amount`. Never multiply `discount_amount` by quantity a second time.

### `payments`

| Column | Meaning |
| --- | --- |
| `payment_id` | Payment-attempt identifier |
| `order_id` | Parent order |
| `amount` | Amount attempted or captured |
| `status` | `captured` for successful capture or `failed` for an unsuccessful attempt |
| `paid_at` | Attempt timestamp |

Captured amount sums only `captured` rows. Failed attempts remain in the database to demonstrate reconciliation and the dangers of joining payment detail directly to line detail. Refunds are separate events rather than negative payment rows.

### `refunds`

| Column | Meaning |
| --- | --- |
| `refund_id` | Refund-event identifier |
| `order_id` | Parent order |
| `amount` | Positive refunded amount |
| `refunded_at` | Refund-event timestamp |
| `reason` | Explanation for the refund |

Refunds are recorded at order level. The model does not identify returned products, quantities, or restored inventory. Reports subtract refunds from the original order's value; cash-flow analysis by `refunded_at` is a separate question.

### `inventory_movements`

| Column | Meaning |
| --- | --- |
| `movement_id` | Stock-movement identifier |
| `product_id` | Affected product |
| `order_id` | Related order when applicable; opening inventory has no order |
| `quantity_delta` | Signed units: positive adds stock, negative removes or reserves it |
| `reason` | Movement explanation; reservation procedure writes `reservation` |
| `created_at` | Movement timestamp |

The fixture's opening stock is an independent current snapshot. Seeded historical orders do not decrement it. New reservations update stock and append a movement atomically. This model has no automated reservation expiration or release.

## Financial reporting contract

The order financial view keeps exactly one row per order. It aggregates each many-row child independently before joining it to the header.

| Term | Calculation |
| --- | --- |
| `gross_sales` | Sum of line quantity times historical price |
| `discounts` | Sum of total line discounts |
| `net_sales` | `gross_sales - discounts` |
| `cost_of_goods` | Sum of line quantity times historical cost |
| `captured_amount` | Sum of captured payment amounts |
| `refund_amount` | Sum of all refund amounts for the order |
| `net_revenue` | `net_sales - refund_amount` for qualifying orders; zero for other statuses |
| `gross_profit` | `net_revenue - cost_of_goods` for qualifying orders; zero for other statuses |

Views may expose non-qualifying orders for reconciliation. Sales analyses must apply the qualifying-status rule explicitly. Taxes, shipping, payment-processing fees, exchange rates, and restocked cost of goods are outside the model. Product rankings use net sales before order-level refunds because the model has no defensible refund allocation to products.

## Time and customer analysis

- The baseline report window is `[2025-01-01, 2026-01-01)`. Half-open windows prevent double-counting at adjacent boundaries.
- RFM and churn analyses use the fixed cutoff `2026-01-01`; they do not drift when the script runs later.
- Acquisition cohorts use the month of a customer's first qualifying purchase, not signup month.
- Retention counts distinct customers with a qualifying purchase in an observable cohort age. One customer with several orders still counts once in that month.
- June is deliberately empty. A date spine preserves it in monthly reports so a missing row is not confused with a zero-sales month.
- The fixture guarantees at least 20 customers who never place an order. Buyer-only segment reports should not silently treat them as purchasers.

## Integrity boundaries

Primary keys, foreign keys, unique keys, and row-level checks enforce structural rules. Cross-row rules such as aggregate refunds not exceeding order value require analytical checks; a row-level `CHECK` cannot enforce a sum across child rows. `06_tests.sql` exercises the fixture and reservation behavior, while the procedure provides the transactional path for new single-product reservations. Direct table writes can bypass that workflow.
