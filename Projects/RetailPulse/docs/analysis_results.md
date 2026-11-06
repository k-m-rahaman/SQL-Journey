# RetailPulse: measured sample results

These results were produced by running `sql/01_schema.sql` through `sql/07_performance.sql` against MySQL 8.0.46. The reporting period is **1 January–31 December 2025**, with customer and stock analysis as of **1 January 2026**.

The data is deterministic and fictional. Its patterns demonstrate SQL techniques and edge cases; they are not evidence about a real retailer or customer population. Recreate a fresh seed to reproduce these exact results. Adding or editing business records will change them.

## Financial control totals

All amounts are INR; tax and shipping are excluded. Recognized orders have status `paid`, `shipped`, or `completed`.

| Metric | Measured result |
| --- | ---: |
| Qualifying orders | 3,240 |
| Purchasing customers | 580 |
| Gross sales before discounts | 13,177,538.00 |
| Discounts | 131,145.60 |
| Sales after discounts, before refunds | 13,046,392.40 |
| Refunds | 113,148.86 |
| Net revenue | **12,933,243.54** |
| Original cost of goods sold | 6,417,540.00 |
| Gross profit after refunds | **6,515,703.54** |
| Net average order value | 3,991.74 |
| Gross margin | 50.38% |

The arithmetic reconciles: `gross sales − discounts − refunds = net revenue`, and `net revenue − original item cost = gross profit`. Refunds are assigned to their original order's period and channel. Costs are not reversed because a refund does not establish that physical goods were returned to stock. This report is not a cash-flow statement.

## Observed findings

### 1. The empty month is represented correctly

Query 02 returns all 12 calendar months. June has **zero orders and zero revenue**, so its change from May is **−100.00%**. July has **300 qualifying orders** and **1,200,711.56** in net revenue; its percentage change from June is **`NULL`**, because division by a zero comparison base is undefined. The fixture deliberately contains no June orders; this does not establish an operational outage.

### 2. Mobile leads revenue while channel margins are close

Query 12 produces the following channel results. Refund percentages count orders with any refund, rather than individual refund events.

| Channel | Qualifying orders | Net revenue | Gross margin | Refunded orders | Refunded order rate |
| --- | ---: | ---: | ---: | ---: | ---: |
| Mobile | 1,081 | 4,577,730.30 | 50.44% | 66 | 6.11% |
| Marketplace | 1,076 | 4,326,159.60 | 50.25% | 64 | 5.95% |
| Web | 1,083 | 4,029,353.64 | 50.46% | 59 | 5.45% |

Mobile generates the most net revenue in this sample, while web has the highest displayed margin and the lowest refunded-order rate. The data contains no acquisition or advertising costs, so it cannot establish channel return on investment.

### 3. Product sales and stock risk answer different questions

In query 03, **Mechanical Keyboard** leads Electronics with **1,095 units** and **3,566,219.00** in sales after discounts, before refunds. That is **27.33%** of all qualifying pre-refund sales. **Travel Backpack** leads Travel with **1,088 units** and **2,049,021.00** in sales before refunds. Order-level refunds cannot be assigned reliably to products in this model, so these amounts must not be presented as product net revenue.

Query 11 identifies three positive reorder suggestions using a 30-day target based on the trailing 90 days of demand:

| Product | Current stock | Units sold in trailing 90 days | Estimated days of stock | Suggested reorder units |
| --- | ---: | ---: | ---: | ---: |
| Travel Backpack | 5 | 293 | 1.5 | 93 |
| Wireless Headphones | 12 | 110 | 9.8 | 25 |
| Yoga Mat | 8 | 35 | 20.6 | 4 |

Stock is an independent current snapshot supported by opening ledger entries. Imported historical orders are not replayed against that opening stock. The scenario does not model lead time, safety stock, pending supply, seasonality, or returned goods.

### 4. Retention is monthly activity, not a cumulative survival rate

The January first-purchase cohort contains **220 customers**. Of those, **157** purchased in February (**71.36%** month-one retention), and **160** purchased in December (**72.73%** month-eleven retention). A customer can return after inactive months, so later monthly retention can increase. Query 05 displays observed zero-activity months and omits future, unobserved cohort cells.

Query 08 attributes **10,622,624.99**, or **82.13%** of annual net revenue, to **2,660 repeat orders**. Query 09 lists **248** repeat customers inactive for at least 90 days as of the cutoff; this is a review population, not proof of churn. Query 13 returns **20** registered customers without a qualifying purchase.

## Proposed actions to explore

These are exercises suggested by the observed results, not tested business outcomes.

- Check stock and supplier lead times for the three reorder candidates before placing orders.
- Compare refund reasons and product mix across channels before changing acquisition spending.
- Test a controlled retention campaign with a holdout group for inactive repeat customers; measure incremental profit rather than assuming the entire population has churned.
- Investigate missing periods in a real dataset by checking source completeness and operating calendars before attributing them to changes in demand.

## Reproduction checks

The supplied fixture has **600 customers, 6 categories, 24 products, 3,600 orders, 7,200 item lines, 3,640 payment attempts, 378 refund events, and 24 opening inventory movements**. There are **189 refunded qualifying orders**, with two partial refunds each. Failed attempts coexist with captures, so raw joins between items, payments, and refunds would multiply amounts.

The 13 numbered analytical queries return these row counts on the unchanged fixture:

| Query | Result | Rows |
| --- | --- | ---: |
| 01 | Executive KPIs | 1 |
| 02 | Calendar months | 12 |
| 03 | Top three sales ranks per category | 18 |
| 04 | Purchaser RFM scores | 580 |
| 05 | Observed cohort/month combinations | 68 |
| 06 | Selling dates with cumulative revenue | 335 |
| 07 | Top product pairs | 10 |
| 08 | First and repeat order groups | 2 |
| 09 | Inactive repeat customers | 248 |
| 10 | Payment reconciliation exceptions | **0** |
| 11 | Product stock reviews | 24 |
| 12 | Channel economics | 3 |
| 13 | Registered nonbuyers | 20 |

These are fixture expectations, not universal query guarantees: for example, `DENSE_RANK` retains ties and can return more than three products per category. Query 10's empty result means no supplied orders violate its reconciliation conditions. A batch client may omit the header for that empty result.

`sql/06_tests.sql` returned `PASS: fixture, financial controls, constraints, reservation and rollback`, with verified net revenue **12,933,243.54**. It independently computes revenue from base tables, checks reporting grain and ledger reconciliation, and exercises reservation success, invalid inputs, constraints, and rollback after an injected ledger failure. A successful rerun also passed; test records were cleaned up. `sql/07_performance.sql` contains four additional plan inspections; their timings depend on hardware and cache and are not a speedup claim.
