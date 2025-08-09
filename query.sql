WITH


 # Calculate account metrics grouped by date, country, send interval, verification and subscription status
 account_metrics AS (
 SELECT
   ses.date,
   ses_par.country,
   acc.send_interval,
   acc.is_verified,
   acc.is_unsubscribed,
   COUNT(acc_ses.account_id) AS account_cnt
 FROM
   `DA.account_session` AS acc_ses
 JOIN
   `DA.account` AS acc
 ON
   acc_ses.account_id = acc.id
 JOIN
   `DA.session` AS ses
 ON
   acc_ses.ga_session_id = ses.ga_session_id
 JOIN
   `DA.session_params` AS ses_par
 ON
   ses.ga_session_id = ses_par.ga_session_id
 GROUP BY
   ses.date,
   ses_par.country,
   acc.send_interval,
   acc.is_verified,
   acc.is_unsubscribed ),




 # Calculate email metrics (sent, opened, clicked) grouped by date, country, send interval, verification and subscription status
 emails_metrics AS (
 SELECT
   DATE_ADD(ses.date, INTERVAL sent.sent_date DAY) AS date,
   ses_par.country,
   acc.send_interval,
   acc.is_verified,
   acc.is_unsubscribed,
   COUNT(DISTINCT sent.id_message) AS sent_msg,
   COUNT(DISTINCT open.id_message) AS open_msg,
   COUNT(DISTINCT visit.id_message) AS visit_msg
 FROM
   `DA.session` AS ses
 JOIN
   `DA.account_session` AS acc_ses
 ON
   ses.ga_session_id = acc_ses.ga_session_id
 JOIN
   `DA.email_sent` AS sent
 ON
   acc_ses.account_id = sent.id_account
 LEFT JOIN
   `DA.email_open` AS open
 ON
   sent.id_message = open.id_message
 LEFT JOIN
   `DA.email_visit` AS visit
 ON
   sent.id_message = visit.id_message
 JOIN
   `DA.session_params` AS ses_par
 ON
   ses.ga_session_id = ses_par.ga_session_id
 JOIN
   `DA.account` AS acc
 ON
   acc_ses.account_id = acc.id
 GROUP BY
   DATE_ADD(ses.date, INTERVAL sent.sent_date DAY),
   ses_par.country,
   acc.send_interval,
   acc.is_verified,
   acc.is_unsubscribed ),




 # Combine account and email metrics into one dataset, setting missing metric values to zero
 unioned_all AS (
 SELECT
   date,
   country,
   send_interval,
   is_verified,
   is_unsubscribed,
   account_cnt,
   0 AS sent_msg,
   0 AS open_msg,
   0 AS visit_msg
 FROM
   account_metrics
 UNION ALL
 SELECT
   date,
   country,
   send_interval,
   is_verified,
   is_unsubscribed,
   0 AS account_cnt,
   sent_msg,
   open_msg,
   visit_msg
 FROM
   emails_metrics ),




 # Aggregate combined metrics to consolidate zeros and get totals per group
 all_metrics AS (
 SELECT
   date,
   country,
   send_interval,
   is_verified,
   is_unsubscribed,
   SUM(account_cnt) AS account_cnt,
   SUM(sent_msg) AS sent_msg,
   SUM(open_msg) AS open_msg,
   SUM(visit_msg) AS visit_msg
 FROM
   unioned_all
 GROUP BY
   date,
   country,
   send_interval,
   is_verified,
   is_unsubscribed ),




 # Calculate total metrics per country and assign ranks for created accounts and sent emails
 ranks AS (
 SELECT
   *,
   DENSE_RANK() OVER (ORDER BY total_acc DESC) AS rank_acc,
   DENSE_RANK() OVER (ORDER BY total_sent DESC) AS rank_sent,
 FROM (
   SELECT
     *,
     SUM(account_cnt) OVER (PARTITION BY country) AS total_acc,
     SUM(sent_msg)OVER (PARTITION BY country) AS total_sent,
   FROM
     all_metrics ) )




# Output final filtered results: only top 10 countries by account or sent email ranks
SELECT
 *
FROM
  ranks
WHERE
  rank_acc <= 10
  OR rank_sent <= 10
ORDER BY
  date,
  country;
