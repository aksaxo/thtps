# Take Home Task - proSapient

Hi here is my analytics engineering take home task!

---

## 🗼 Project Structure

The dbt project includes staging, intermediate, mart, and presentation layers. 

I considered other granularities for the presentation level table (e.g. 1 row per customer per segment per month), but I decided
on having one big and very granular transactions table to enable most flexibility when exploring in Tableau later. 

### 📁 Models Overview

- **Staging Layer**: Cleans and standardises raw source tables (`customers`, `transactions`, `products`)
- **Intermediate Layer**: Contains business logic to segment customers based on their spending habits
- **Mart Layer**: Contains dims and fcts (e.g. dim_customers, fct_transactions)
- **Presentation Layer**: Final big denormalised table for analytics, which joins customer, transaction, and product information together
