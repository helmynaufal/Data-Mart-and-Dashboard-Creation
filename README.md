# Data-Mart-and-Dashboard-Creation
## **Goals** <br>
Kimia Farma wanted us to create a dashboard using the sales data they provide

## **Dataset** <br>
There are 6 CSV-formatted files used in this project. The dataset comprises sales, products and customer data. Some tables have a similar name and columns to each other, for example `pelanggan` and `pelanggan_ds`. We assume that the dataset is obtained from the data lake from 2 different sources. Therefore, it needs to combine the data first so that it becomes comprehensive data.

## **The Steps Involved** <br>
Here is the list of the steps involved in the notebook to achieve the goal.

**1. Data Extraction** <br>
First, we will import the dataset into the database. I use PostgreSQL to process the data.

**2. Set the Primary Key** <br>
Next, we set the primary key of each table so we can create the tables relationship

**3. Combining Data** <br>
As we stated before, we need to combine the data first. From 6 tables obtained, we will combine the data into 3 tables:
- Sales: `penjualan` and `penjualan_ds`
- Customers: `pelanggan` and `pelanggan_ds`
- Products: `barang` and `barang_ds`

**4. Create Table Base** <br>
The table base will be created from the 3 tables that have been combined before. ‘Id_sales’ column will be the primary key. Table base will be stored in data warehouse.

**5. Create Table Aggregate** <br>
There are several table aggregate will be created from table base. Table aggregate will be stored in data mart.

**6. Visualize using Dashboard** <br>
Here, we use Looker Studio to create a dashboard. We can check the dashboard [here](https://lookerstudio.google.com/reporting/cf5806ed-c892-4925-a689-cc1a853deb64)
![Dashboard](/image/Dashboard.png)
