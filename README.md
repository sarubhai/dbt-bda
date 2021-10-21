DBT project for Big Data Analytics with Snowflake Target.

## Pre-requisite

- Snowflake Account
- DBT Locally Installed
- Clone the Git Repository

### Snowsql Config (~/.snowsql/config):

```
[connections]
accountname=ab12345.southeast-asia.azure
username=johndoe
password='P@ssw0rd!23456'
rolename=SYSADMIN
log_file=~/.snowsql/snowsql_rt.log
```

### Snowsql Commands:

```
export dbname=BDA
export schemaname=CAR
export stagename=SF_INT_STAGE
export warehousename=BDA_WH
export filepath=`pwd`
```

```
snowsql --config ~/.snowsql/config --variable dbname=$dbname --variable schemaname=$schemaname --variable stagename=$stagename --variable warehousename=$warehousename --variable filepath=$filepath
!set variable_substitution=true;
CREATE DATABASE &dbname COMMENT = 'Big Data Analytics Database';
CREATE SCHEMA &dbname.&schemaname COMMENT = 'Car Sales Schema';
CREATE STAGE &dbname.&schemaname.&stagename COMMENT = 'Snowflake Internal Stage';
CREATE WAREHOUSE &warehousename WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 300 AUTO_RESUME = TRUE COMMENT = 'Big Data Analytics Warehouse';


USE DATABASE &dbname;
USE SCHEMA &schemaname;

CREATE TABLE car.dates(
  year_number INTEGER NOT NULL,
  month_number INTEGER NOT NULL,
  day_of_year_number INTEGER NOT NULL,
  day_of_month_number INTEGER NOT NULL,
  day_of_week_number INTEGER NOT NULL,
  week_of_year_number INTEGER NOT NULL,
  day_name VARCHAR(10) NOT NULL,
  month_name VARCHAR(10) NOT NULL,
  quarter_number INTEGER NOT NULL,
  quarter_name VARCHAR(2) NOT NULL,
  year_quarter_name VARCHAR(6) NOT NULL,
  weekend_ind VARCHAR(1) NOT NULL,
  days_in_month_qty INTEGER NOT NULL,
  date_sk INTEGER NOT NULL,
  day_desc DATE NOT NULL,
  week_sk INTEGER NOT NULL,
  day_date DATE NOT NULL,
  week_name VARCHAR(7) NOT NULL,
  week_of_month_number INTEGER NOT NULL,
  week_of_month_name VARCHAR(3) NOT NULL,
  month_sk INTEGER NOT NULL,
  quarter_sk INTEGER NOT NULL,
  year_sk INTEGER NOT NULL,
  year_sort_number INTEGER NOT NULL,
  day_of_week_sort_name VARCHAR(7) NOT NULL
);

CREATE TABLE car.customer(
  id INTEGER NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50),
  gender VARCHAR(50),
  dob DATE,
  company VARCHAR(50),
  job VARCHAR(50),
  email VARCHAR(50) NOT NULL,
  country VARCHAR(50),
  state VARCHAR(50),
  address VARCHAR(50),
  update_date TIMESTAMP NOT NULL,
  create_date TIMESTAMP NOT NULL
);

create table car.product (
  id INTEGER NOT NULL,
  code VARCHAR(50) NOT NULL,
  category VARCHAR(6) NOT NULL,
  make VARCHAR(50) NOT NULL,
  model VARCHAR(50) NOT NULL,
  year INTEGER NOT NULL,
  color VARCHAR(50),
  price INTEGER NOT NULL,
  currency VARCHAR(3) NOT NULL,
  update_date TIMESTAMP NOT NULL,
  create_date TIMESTAMP NOT NULL
);

create table car.showroom (
  id INTEGER NOT NULL,
  code VARCHAR(40) NOT NULL,
  name VARCHAR(50) NOT NULL,
  operation_date DATE,
  staff_count INTEGER,
  country VARCHAR(50) NOT NULL,
  state VARCHAR(50) NOT NULL,
  address VARCHAR(50),
  update_date TIMESTAMP NOT NULL,
  create_date TIMESTAMP NOT NULL
);

create table car.sales (
  id INTEGER NOT NULL ,
  order_number VARCHAR(50) NOT NULL,
  customer_id INTEGER NOT NULL,
  showroom_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  discount INTEGER,
  amount INTEGER,
  delivered VARCHAR(50),
  card_type VARCHAR(50) NOT NULL,
  card_number VARCHAR(50) NOT NULL,
  txn_date DATE,
  update_date TIMESTAMP NOT NULL,
  create_date TIMESTAMP NOT NULL
);

create table car.stocks (
  id INTEGER NOT NULL,
  showroom_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  stock_date DATE NOT NULL,
  update_date TIMESTAMP NOT NULL,
  create_date TIMESTAMP NOT NULL
);


PUT file://&filepath/datasets/dates/dates.psv @&stagename/dates ;
PUT file://&filepath/datasets/customer/customer.psv @&stagename/customer;
PUT file://&filepath/datasets/product/product.psv @&stagename/product;
PUT file://&filepath/datasets/showroom/showroom.psv @&stagename/showroom;
PUT file://&filepath/datasets/sales/sales.psv @&stagename/sales;
PUT file://&filepath/datasets/stocks/stocks.psv @&stagename/stocks;


COPY INTO car.dates FROM @&stagename/dates/ file_format = (type = csv field_delimiter = '|' skip_header = 1);
COPY INTO car.customer FROM @&stagename/customer/ file_format = (type = csv field_delimiter = '|' skip_header = 1);
COPY INTO car.product FROM @&stagename/product/ file_format = (type = csv field_delimiter = '|' skip_header = 1);
COPY INTO car.showroom FROM @&stagename/showroom/ file_format = (type = csv field_delimiter = '|' skip_header = 1);
COPY INTO car.sales FROM @&stagename/sales/ file_format = (type = csv field_delimiter = '|' skip_header = 1);
COPY INTO car.stocks FROM @&stagename/stocks/ file_format = (type = csv field_delimiter = '|' skip_header = 1);


UPDATE car.sales sales
SET amount = sales.quantity * product.price
FROM car.product product
WHERE sales.product_id = product.id;


!quit
```

### DBT Profile (~/.dbt/profiles.yml):

```
dbt-bda-snowflake-profile:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: ab12345.southeast-asia.azure

      # User/password auth
      user: johndoe
      password: P@ssw0rd!23456

      role: sysadmin
      database: BDA
      warehouse: BDA_WH
      schema: CAR
      threads: 1
      client_session_keep_alive: False
      query_tag: DBT-BDA
```

### DBT Commands:

- dbt deps
- dbt debug
- dbt run
- dbt test
- dbt clean
