CREATE DATABASE wolt_ops;
USE wolt_ops;
CREATE TABLE cities (
  city_id INT PRIMARY KEY,
  city_name VARCHAR(50),
  country VARCHAR(5),
  sla_target_mins INT,
  population INT
);

CREATE TABLE couriers (
  courier_id VARCHAR(20) PRIMARY KEY,
  city_id INT,
  onboard_date DATE,
  status VARCHAR(20),
  rating DECIMAL(3,2)
);

CREATE TABLE orders (
  order_id VARCHAR(20) PRIMARY KEY,
  created_at DATETIME,
  picked_at DATETIME,
  delivered_at DATETIME,
  city_id INT,
  courier_id VARCHAR(20),
  distance_km DECIMAL(5,2),
  order_value DECIMAL(6,2),
  cancelled BOOLEAN,
  complaint_flag BOOLEAN,
  reason_cancel VARCHAR(100)
);

CREATE TABLE courier_shifts (
  shift_id VARCHAR(20) PRIMARY KEY,
  courier_id VARCHAR(20),
  city_id INT,
  date DATE,
  online_hours DECIMAL(3,2),
  acceptance_rate DECIMAL(3,2),
  completion_rate DECIMAL(3,2),
  earnings_eur DECIMAL(6,2)
);

CREATE TABLE okrs (
  okr_id VARCHAR(20) PRIMARY KEY,
  city_id INT,
  week_start DATE,
  target_avg_delivery_mins DECIMAL(5,2),
  target_cancellation_rate DECIMAL(3,2),
  notes VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS courier_onboard (
    activated_at DATE,
    courier_id VARCHAR(20),
    city_id INT
);

CREATE TABLE IF NOT EXISTS complaints (
    complaint_id VARCHAR(20) PRIMARY KEY,
    city_id INT,
    courier_id VARCHAR(20),
    order_id VARCHAR(20),
    category VARCHAR(50),
    complaint_date DATE
);

