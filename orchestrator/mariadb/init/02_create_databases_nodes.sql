CREATE DATABASE IF NOT EXISTS remotedb;

USE remotedb;

CREATE TABLE IF NOT EXISTS warehouse (
    w_id INT PRIMARY KEY,
    w_name VARCHAR(32),
    w_city VARCHAR(32)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS district (
    d_w_id INT,
    d_id INT,
    d_name VARCHAR(32),
    d_city VARCHAR(32),
    PRIMARY KEY(d_w_id,d_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS customer (
    c_w_id INT,
    c_d_id INT,
    c_id INT,
    c_first VARCHAR(32),
    c_last VARCHAR(32),
    c_city VARCHAR(32),
    PRIMARY KEY(c_w_id,c_d_id,c_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS orders (
    o_w_id INT,
    o_d_id INT,
    o_id INT,
    o_c_id INT,
    o_entry_d TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(o_w_id,o_d_id,o_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS order_line (
    ol_w_id INT,
    ol_d_id INT,
    ol_o_id INT,
    ol_number INT,
    ol_i_id INT,
    ol_quantity INT,
    ol_amount DECIMAL(12,2),
    PRIMARY KEY(ol_w_id,ol_d_id,ol_o_id,ol_number)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS new_order (
    no_w_id INT,
    no_d_id INT,
    no_o_id INT,
    PRIMARY KEY(no_w_id,no_d_id,no_o_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS stock (
    s_w_id INT,
    s_i_id INT,
    s_quantity INT,
    PRIMARY KEY(s_w_id,s_i_id)
) ENGINE=InnoDB;