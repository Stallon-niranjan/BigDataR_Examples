--------------------------------------------------
--              Small Data Section              --
--------------------------------------------------

-- small data click matrix
drop table if exists small_data_click_matrix;
create table small_data_click_matrix as 
select 
       userid_id
       ,sku_id
       ,count(*)
from small_data_random_train 
group by userid_id, sku_id;

-- small data query matrix
drop table if exists small_data_query_matrix;
create table small_data_query_matrix as 
select 
       query_id
       ,sku_id
       ,count(*)
from small_data_random_train 
group by query_id, sku_id;


-- small data query matrix
drop table if exists big_data_query_matrix;
create table big_data_query_matrix as 
select 
       query_id
       ,sku_id
       ,count(*) 
from big_data_random_train 
group by query_id, sku_id;

-- create a mapping for matrix market format -- small data
drop table if exists small_data_sku_map;
drop table if exists small_data_query_map;
create table small_data_sku_map as select distinct sku_id from small_data_query_matrix;
create table small_data_query_map as select distinct query_id from small_data_query_matrix;
alter table small_data_sku_map add matrix_market_sku_id serial;
alter table small_data_query_map add matrix_market_query_id serial;

-- create a mapping file for the prediction code to lookup real sku values
drop table if exists small_data_sku_mapping;
create table small_data_sku_mapping as
select 
  a.sku
  ,a.sku_id
from small_data_random_train a, small_data_sku_map b
where a.sku_id = b.sku_id
UNION
select distinct 
  a.sku
  ,a.sku_id
from small_data_random_test a;

-- create the matrix market file
drop table if exists small_data_query_matrix_market;
create table small_data_query_matrix_market as
  select
    a.matrix_market_sku_id
    ,b.matrix_market_query_id
    ,c.count
  from small_data_query_matrix c, small_data_query_map b, small_data_sku_map a
  where c.sku_id = a.sku_id and b.query_id = c.query_id;
  
-- verify counts, otherwise, our join failed
select case when 
       (select count(*) from small_data_query_matrix_market) = (select count(*) from small_data_query_matrix) 
       then 'Success. Matrix Market file made.'
       else 'Fail. Matrix Market counts did not match' end as Message;


--------------------------------------------------
--              BIG Data Section                --
--------------------------------------------------

-- big data click matrix
drop table if exists big_data_click_matrix;
create table big_data_click_matrix as 
select 
       userid_id
       ,sku_id
       ,count(*) 
from big_data_random_train 
group by userid_id, sku_id;

-- create a mapping for matrix market format -- big data
drop table if exists big_data_sku_map;
drop table if exists big_data_query_map;
create table big_data_sku_map as select distinct sku_id from big_data_query_matrix;
create table big_data_query_map as select distinct query_id from big_data_query_matrix;
alter table big_data_sku_map add matrix_market_sku_id serial;
alter table big_data_query_map add matrix_market_query_id serial;

-- create a mapping file for the prediction code to lookup real sku values
drop table if exists big_data_sku_mapping;
create table big_data_sku_mapping as
select 
  a.sku
  ,a.sku_id
from big_data_random_train a, big_data_sku_map b
where a.sku_id = b.sku_id
UNION
select distinct 
  a.sku
  ,a.sku_id
from big_data_random_test a;

-- create the matrix market file
drop table if exists big_data_query_matrix_market;
create table big_data_query_matrix_market as
  select
    a.matrix_market_sku_id
    ,b.matrix_market_query_id
    ,c.count
  from big_data_query_matrix c, big_data_query_map b, big_data_sku_map a
  where c.sku_id = a.sku_id and b.query_id = c.query_id;
  
-- verify counts, otherwise, our join failed
select case when 
       (select count(*) from big_data_query_matrix_market) = (select count(*) from big_data_query_matrix) 
       then 'Success. Matrix Market file made.'
       else 'Fail. Matrix Market counts did not match' end as Message;




COPY small_data_sku_mapping to '/mnt/small_data_sku_mapping' with csv;
COPY big_data_query_matrix TO '/mnt/big_data_query_matrix' WITH CSV;
COPY big_data_click_matrix TO '/mnt/big_data_click_matrix' WITH CSV;
COPY small_data_query_matrix_market TO '/mnt/small_data_query_matrix' WITH CSV;
COPY small_data_click_matrix TO '/mnt/small_data_click_matrix' WITH CSV;