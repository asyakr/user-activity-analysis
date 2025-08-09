# User Activity Analysis

## Project Description

This project uses an e-commerce database from BigQuery to analyze user account creation dynamics and email engagement activity. The goal is to gather data that helps:

- Track the trends of account creation over time  
- Measure user email activity such as emails sent, opened, and clicked  
- Evaluate user behavior by segments including send interval, account verification, and subscription status  
- Compare user activity between countries to identify key markets  
- Segment users based on multiple parameters for deeper insights

## Metrics

### Main metrics:
- `account_cnt` – number of created accounts  
- `sent_msg` – number of sent emails  
- `open_msg` – number of opened emails  
- `visit_msg` – number of link clicks in emails  

### Additional metrics:
- `total_country_account_cnt` – total accounts per country  
- `total_country_sent_cnt` – total sent emails per country  
- `rank_total_country_account_cnt` – country rank by accounts  
- `rank_total_country_sent_cnt` – country rank by sent emails  

## Dimensions

Data is aggregated by:  
- `date` – account creation date or email sent date  
- `country` – user country  
- `send_interval` – account’s sending interval  
- `is_verified` – account verification status  
- `is_unsubscribed` – subscription status  

## SQL Logic

- **CTEs** – used to separate account metrics and email metrics  
- **Window functions** – for country ranking  
- **UNION** – to combine account and email data while keeping separate date logic  
- **Filtering** – only top 10 countries by accounts or emails are included 

## SQL Query Overview

The SQL query implements this analysis by performing the following steps:

- **Account Metrics:** Aggregates the number of created accounts by date, country, send interval, verification status, and subscription status.  
- **Email Metrics:** Aggregates email metrics (sent, opened, clicked) using the same grouping, adjusting the date according to the email sent date.  
- **Combine Data:** Merges account and email metrics into one dataset, filling missing metric values with zeros to avoid conflicts.  
- **Aggregate:** Sums the combined metrics per segment to consolidate data.  
- **Ranking:** Calculates total account and email activity per country and assigns ranks to identify the top 10 countries by each metric.  
- **Filtering:** Filters results to only include records from the top 10 countries by account creation or email sends, ordered by date and country.

You can view the full, commented SQL query in the [`query.sql`](./query.sql) file.

## File Structure

- `query.sql` — SQL query with comments  
- `README.md` — project description  
- `results/results_sample.csv` — first 10 sample query results 
- `screenshots/query_execution.png` — screenshot of query execution 
- `docs/analysis_notes.md` — analysis summary

## Author

Asya Krasniukevych  
[LinkedIn: www.linkedin.com/in/anastasiia-krasniukevych]
