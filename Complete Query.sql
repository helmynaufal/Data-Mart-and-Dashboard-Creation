/* DATA PREPARATION */
CREATE TABLE pelanggan (
    id_customer VARCHAR(10) PRIMARY KEY,
    levels VARCHAR(10),
    nama VARCHAR(30),
    id_cabang_sales VARCHAR(10),
    cabang_sales VARCHAR(30),
    id_group VARCHAR(10),
    group_type VARCHAR(10)
);

COPY PELANGGAN(ID_CUSTOMER, LEVELS, NAMA, ID_CABANG_SALES, CABANG_SALES, ID_GROUP, GROUP_TYPE)
FROM 'D:/VIX/Kimia Farma/dataset/pelanggan.csv'
DELIMITER ';'
CSV HEADER;

CREATE TABLE pelanggan_ds (
    id_customer VARCHAR(10) PRIMARY KEY,
    levels VARCHAR(10),
    nama VARCHAR(30),
    id_cabang_sales VARCHAR(10),
    cabang_sales VARCHAR(30),
    id_distributor VARCHAR(50),
    group_type VARCHAR(10)
);

COPY pelanggan_ds(id_customer, levels, nama, id_cabang_sales, cabang_sales, id_distributor, group_type)
FROM 'D:/VIX/Kimia Farma/dataset/pelanggan_ds.csv'
DELIMITER ';'
CSV HEADER;

CREATE TABLE barang (
    kode_barang VARCHAR(10) PRIMARY KEY,
    sektor VARCHAR(5),
    nama_barang VARCHAR(50),
    tipe VARCHAR(5),
    nama_tipe VARCHAR(20),
    kode_lini VARCHAR(5),
    lini VARCHAR(10),
    kemasan VARCHAR(10)
);

COPY barang(kode_barang, sektor, nama_barang, tipe, nama_tipe, kode_lini, lini, kemasan)
FROM 'D:/VIX/Kimia Farma/dataset/barang.csv'
DELIMITER ';'
CSV HEADER;

CREATE TABLE barang_ds (
    kode_barang varchar(10) PRIMARY KEY,
	 nama_barang varchar(50),
    kemasan varchar(10),
    harga int,
    nama_tipe varchar(20),
    kode_brand varchar(5),
    brand varchar(10)
);

COPY barang_ds(kode_barang, nama_barang, kemasan, harga, nama_tipe, kode_brand, brand)
FROM 'D:/VIX/Kimia Farma/dataset/barang_ds.csv'
DELIMITER ';'
CSV HEADER;

CREATE TABLE penjualan (
    id_sales varchar(30),
    id_distributor VARCHAR(5),
    id_cabang VARCHAR(5),
    id_invoice VARCHAR(10),
    tanggal DATE,
    id_customer VARCHAR(10) REFERENCES pelanggan (id_customer),
    id_barang VARCHAR(10) REFERENCES barang (kode_barang),
    jumlah_barang INT,
    unit VARCHAR(10),
    harga numeric,
    mata_uang VARCHAR(5),
    brand_id VARCHAR(10),
    lini VARCHAR(10)
);

COPY penjualan(id_distributor, id_cabang, id_invoice, tanggal, id_customer, id_barang, jumlah_barang, unit, harga, mata_uang, brand_id, lini)
FROM 'D:/VIX/Kimia Farma/dataset/penjualan.csv'
DELIMITER ';'
CSV HEADER;

CREATE TABLE penjualan_ds (
    id_sales varchar(30),
    id_invoice VARCHAR(10),
    tanggal DATE,
    id_customer VARCHAR(10) REFERENCES pelanggan_ds (id_customer),
    id_barang VARCHAR(10)REFERENCES barang_ds (kode_barang),
    jumlah_barang INT,
    unit VARCHAR(10),
    harga INT,
    mata_uang VARCHAR(5)
);

COPY penjualan_ds(id_invoice, tanggal, id_customer, id_barang, jumlah_barang, unit, harga, mata_uang)
FROM 'D:/VIX/Kimia Farma/dataset/penjualan_ds.csv'
DELIMITER ';'
CSV HEADER;

UPDATE penjualan
SET id_sales = concat(id_invoice, '_', id_barang);
ALTER TABLE penjualan ADD PRIMARY KEY (id_sales);

UPDATE penjualan_ds
SET id_sales = concat(id_invoice, '_', id_barang);
ALTER TABLE penjualan_ds ADD PRIMARY KEY (id_sales);

/* TABLE BASE */
CREATE TEMPORARY TABLE sales AS
   (SELECT id_sales, id_invoice, tanggal, id_customer, id_barang, jumlah_barang
    FROM penjualan);

MERGE INTO sales s USING penjualan_ds pds ON s.id_sales = pds.id_sales 
WHEN matched THEN 
UPDATE
SET id_sales = s.id_sales, id_invoice = s.id_invoice, tanggal = s.tanggal, id_customer = s.id_customer, 
    id_barang = s.id_barang, jumlah_barang = s.jumlah_barang 
WHEN NOT matched THEN
INSERT (id_sales, id_invoice, tanggal, id_customer, id_barang,jumlah_barang)
VALUES (pds.id_sales, pds.id_invoice, pds.tanggal, pds.id_customer, pds.id_barang, pds.jumlah_barang);

CREATE TABLE sales_report AS
   (WITH customers AS
          (SELECT p.id_customer, p.nama, p.cabang_sales AS cabang,
                  pds.id_distributor AS distributor, p.group_type
           FROM pelanggan p 
           JOIN pelanggan_ds pds ON p.id_customer = pds.id_customer),
         products AS
          (SELECT b.kode_barang, b.nama_barang, b.kemasan, bds.brand, bds.harga
           FROM barang b 
           JOIN barang_ds bds ON b.kode_barang = bds.kode_barang)
   SELECT s.id_sales, s.id_invoice, s.tanggal, c.id_customer, c.nama, c.cabang, p.nama_barang, p.harga,
          s.jumlah_barang, p.kemasan, (p.harga * s.jumlah_barang) AS total_harga, 
          p.brand, c.distributor, c.group_type
   FROM sales s
   JOIN customers c ON s.id_customer = c.id_customer
   JOIN products p ON s.id_barang = p.kode_barang);

UPDATE sales_report
SET id_invoice = replace(replace(replace(replace(id_invoice, 'IN6028', 'IN6328'),
                                                             'IN6064', 'IN6329'),
                                                             'IN6113', 'IN6330'),
                                                             'IN6131', 'IN6331')
WHERE id_sales in ('IN6028_BRG0001','IN6064_BRG0006','IN6113_BRG0001','IN6131_BRG0009');
      
UPDATE sales_report
SET id_sales = concat(id_invoice, '_', split_part(id_sales, '_', 2));

/* TABLE AGGREGATE */
-- Monthly Revenue
SELECT to_char(tanggal, 'Month') AS MONTH, sum(total_harga) AS revenue
FROM sales_report
GROUP BY 1
ORDER BY min(tanggal);

-- Total Transaction
SELECT to_char(tanggal, 'Month') AS MONTH, count(DISTINCT id_invoice) AS TRANSACTION
FROM sales_report
GROUP BY 1
ORDER BY min(tanggal);

-- Average Product Sold
SELECT to_char(tanggal, 'Month') AS MONTH, 
       round(avg(jumlah_barang),1) AS avg_product
FROM sales_report
GROUP BY 1
ORDER BY min(tanggal);

-- Seller Type
SELECT group_type as seller_type, count(DISTINCT id_invoice) AS total
FROM sales_report
GROUP BY 1;

-- Top Product
SELECT nama_barang, round(avg(jumlah_barang), 1) AS avg_product
FROM sales_report
GROUP BY 1
ORDER BY 2 DESC;

-- Top Seller
WITH trx AS
      (SELECT nama, count(DISTINCT id_invoice) AS transaction
       FROM sales_report
       GROUP BY 1),
     sell AS
      (SELECT nama, round(avg(jumlah_barang), 2) AS avg_product
       FROM sales_report
       GROUP BY 1)
SELECT t.nama, t.transaction, s.avg_product
FROM trx t
JOIN sell s ON t.nama = s.nama
ORDER BY 3 DESC;

-- Region Sales
WITH rev AS
      (SELECT cabang, sum(total_harga) AS revenue
       FROM sales_report
       GROUP BY 1),
     sell AS
      (SELECT cabang, round(avg(jumlah_barang), 1) AS avg_product
       FROM sales_report
       GROUP BY 1)
SELECT r.cabang, r.revenue, s.avg_product
FROM rev r
JOIN sell s ON r.cabang = s.cabang
ORDER BY 2 DESC;