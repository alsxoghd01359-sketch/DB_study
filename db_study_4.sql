DROP DATABASE IF EXISTS shopdb;
CREATE DATABASE shopdb DEFAULT CHARACTER SET utf8mb4;
USE shopdb;

CREATE TABLE sellers (
	seller_id INT PRIMARY KEY,
	seller_name VARCHAR(30) NOT NULL,
	city VARCHAR(20),
	commission_rate DECIMAL(4,3) -- 플랫폼이 가져가는 수수료율
);

CREATE TABLE categories (
	category_id INT PRIMARY KEY,
	category_name VARCHAR(30) NOT NULL,
	parent_id INT NULL, -- 자기참조 (최대 3단계)
	CONSTRAINT fk_cat_parent FOREIGN KEY (parent_id) REFERENCES categories(category_id)
);

CREATE TABLE members (
	member_id INT PRIMARY KEY,
	name VARCHAR(20) NOT NULL,
	email VARCHAR(50),
	gender CHAR(1),
	birth_date DATE NULL,
	grade VARCHAR(10), -- BRONZE / SILVER / GOLD / VIP
	joined_at DATE NOT NULL,
	city VARCHAR(20),
	referrer_id INT NULL, -- 추천인 (자기참조)
	CONSTRAINT fk_ref FOREIGN KEY (referrer_id) REFERENCES members(member_id)
);

CREATE TABLE products (
	product_id INT PRIMARY KEY,
	product_name VARCHAR(50) NOT NULL,
	category_id INT,
	price INT NOT NULL, -- 현재 판매가
	cost INT NOT NULL, -- 원가
	stock INT DEFAULT 0,
	seller_id INT,
	launched_at DATE,
	discontinued_at DATE NULL, -- NULL이면 판매중
	CONSTRAINT fk_p_cat FOREIGN KEY (category_id) REFERENCES categories(category_id),
	CONSTRAINT fk_p_sel FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE coupons (
	coupon_id INT PRIMARY KEY,
	coupon_name VARCHAR(30),
	discount_type VARCHAR(10), -- RATE / AMOUNT
	discount_value INT,
	min_amount INT DEFAULT 0
);

CREATE TABLE orders (
	order_id INT PRIMARY KEY,
	member_id INT NOT NULL,
	ordered_at DATETIME NOT NULL,
	status VARCHAR(12) NOT NULL, -- PAID/SHIPPED/DELIVERED/CANCELLED/REFUNDED
	coupon_id INT NULL,
	ship_fee INT DEFAULT 0,
	CONSTRAINT fk_o_mem FOREIGN KEY (member_id) REFERENCES members(member_id),
	CONSTRAINT fk_o_cp FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id)
);

CREATE TABLE order_items (
	order_item_id INT AUTO_INCREMENT PRIMARY KEY,
	order_id INT NOT NULL,
	product_id INT NOT NULL,
	qty INT NOT NULL,
	unit_price INT NOT NULL, -- 주문 시점 가격(스냅샷) — products.price와 다를 수 있음
	CONSTRAINT fk_oi_o FOREIGN KEY (order_id) REFERENCES orders(order_id),
	CONSTRAINT fk_oi_p FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
	payment_id INT AUTO_INCREMENT PRIMARY KEY,
	order_id INT NOT NULL,
	method VARCHAR(12),
	amount INT NOT NULL,
	paid_at DATETIME,
	refunded_at DATETIME NULL,
	CONSTRAINT fk_pay_o FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE reviews (
	review_id INT PRIMARY KEY,
	product_id INT NOT NULL,
	member_id INT NOT NULL,
	rating TINYINT NOT NULL,
	content VARCHAR(100),
	created_at DATE,
	CONSTRAINT fk_rv_p FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_rv_m FOREIGN KEY (member_id) REFERENCES members(member_id)
);

INSERT INTO sellers VALUES
	(1,'청담셀렉트','서울',0.100),(2,'대전그로서리','대전',0.080),
	(3,'테크마루','성남',0.120),(4,'코스메랩','서울',0.150);

INSERT INTO categories VALUES
(1,'패션',NULL),(2,'뷰티',NULL),(3,'디지털',NULL),(4,'식품',NULL),
(11,'남성의류',1),(12,'여성의류',1),
(21,'스킨케어',2),(22,'메이크업',2),
(31,'노트북',3),(32,'스마트폰',3),(33,'이어폰',3),
(41,'신선식품',4),(42,'가공식품',4),
(211,'토너',21),(212,'크림',21);

INSERT INTO members VALUES
(1,'김민준','minjun@ex.com','M','1990-03-12','VIP','2023-05-14','서울',NULL),
(2,'이서연','seoyeon@ex.com','F','1995-07-22','GOLD','2023-06-02','대전',1),
(3,'박지훈','jihun@ex.com','M','1988-11-05','SILVER','2023-09-18','부산',1),
(4,'최수아','sua@ex.com','F','2000-01-30','BRONZE','2024-01-07','서울',2),
(5,'정도윤','doyun@ex.com','M','1992-04-18','GOLD','2024-02-21','대구',NULL),
(6,'강하은','haeun@ex.com','F','1998-09-09','SILVER','2024-03-30','인천',2),
(7,'조은우','eunwoo@ex.com','M','1985-12-25','VIP','2024-05-11','서울',NULL),
(8,'윤지아','jia@ex.com','F','2001-06-14','BRONZE','2024-08-03','광주',5),
(9,'임채원','chaewon@ex.com','F','1993-02-28','SILVER','2025-01-19','대전',7),
(10,'한소율','soyul@ex.com','F','1996-10-07','BRONZE','2025-03-22','서울',NULL),
(11,'오태양','taeyang@ex.com','M','1999-08-16','BRONZE','2025-07-04','세종',9),
(12,'배하늘',NULL,'F',NULL,'BRONZE','2026-02-10','제주',NULL);

INSERT INTO products VALUES
(101,'오버핏 코튼 셔츠',11,39000,18000,120,1,'2024-03-01',NULL),
(102,'슬림핏 데님팬츠',11,59000,27000,45,1,'2024-03-15',NULL),
(103,'린넨 원피스',12,78000,33000,0,1,'2024-05-02','2025-09-30'),
(104,'니트 가디건',12,62000,29000,33,1,'2024-09-10',NULL),
(201,'수분 진정 토너 500ml',211,24000,9000,300,4,'2023-11-01',NULL),
(202,'저자극 크림 80ml',212,32000,12000,210,4,'2024-01-20',NULL),
(203,'비타민C 세럼',21,45000,16000,85,4,'2024-06-01',NULL),
(204,'매트 립스틱',22,21000,6000,150,4,'2024-02-14',NULL),
(205,'쿠션 파운데이션',22,38000,14000,0,4,'2023-08-01','2026-01-15'),
(301,'14인치 노트북 X1',31,1290000,950000,12,3,'2024-04-01',NULL),
(302,'16인치 노트북 Pro',31,2450000,1900000,5,3,'2025-02-10',NULL),
(303,'스마트폰 A5',32,890000,640000,40,3,'2024-08-20',NULL),
(304,'무선 이어폰 Air',33,189000,92000,130,3,'2024-07-05',NULL),
(305,'오버이어 헤드폰 H2',33,259000,135000,22,3,'2025-06-01',NULL),
(401,'유기농 사과 3kg',41,28000,17000,60,2,'2025-01-05',NULL),
(402,'한우 등심 500g',41,59000,42000,0,2,'2024-11-11',NULL),
(403,'수제 그래놀라 1kg',42,22000,9500,95,2,'2024-10-01',NULL);

INSERT INTO coupons VALUES
(1,'10% 할인','RATE',10,30000),
(2,'5천원 할인','AMOUNT',5000,20000),
(3,'15% 할인','RATE',15,50000),
(4,'3천원 할인','AMOUNT',3000,0),
(5,'겨울 시즌 20% 할인','RATE',20,100000);

INSERT INTO orders VALUES
(1001,1,'2025-03-05 10:22:00','DELIVERED',1,3000),
(1002,2,'2025-03-11 19:40:00','DELIVERED',NULL,3000),
(1003,3,'2025-04-02 14:05:00','CANCELLED',NULL,3000),
(1004,1,'2025-04-18 09:12:00','DELIVERED',2,0),
(1005,4,'2025-05-07 21:33:00','DELIVERED',NULL,3000),
(1006,5,'2025-05-20 12:00:00','REFUNDED',NULL,3000),
(1007,2,'2025-06-01 08:45:00','DELIVERED',3,0),
(1008,6,'2025-06-15 16:20:00','DELIVERED',NULL,3000),
(1009,7,'2025-06-28 11:10:00','DELIVERED',NULL,0),
(1010,1,'2025-07-04 20:05:00','DELIVERED',4,0),
(1011,8,'2025-07-19 13:55:00','CANCELLED',NULL,3000),
(1012,3,'2025-08-02 17:30:00','DELIVERED',NULL,3000),
(1013,5,'2025-08-23 10:00:00','DELIVERED',2,0),
(1014,7,'2025-09-09 15:45:00','DELIVERED',NULL,0),
(1015,9,'2025-09-27 19:15:00','DELIVERED',1,3000),
(1016,2,'2025-10-11 09:30:00','REFUNDED',NULL,3000),
(1017,4,'2025-10-30 22:10:00','DELIVERED',NULL,3000),
(1018,1,'2025-11-14 12:40:00','DELIVERED',3,0),
(1019,6,'2025-11-29 18:00:00','DELIVERED',NULL,3000),
(1020,10,'2025-12-06 11:25:00','DELIVERED',1,3000),
(1021,7,'2025-12-24 20:50:00','DELIVERED',NULL,0),
(1022,5,'2026-01-08 14:15:00','DELIVERED',NULL,3000),
(1023,9,'2026-01-22 10:35:00','CANCELLED',NULL,3000),
(1024,2,'2026-02-05 16:05:00','DELIVERED',2,0),
(1025,11,'2026-02-27 21:00:00','DELIVERED',1,3000),
(1026,1,'2026-03-15 08:20:00','DELIVERED',NULL,0),
(1027,8,'2026-04-02 13:10:00','DELIVERED',NULL,3000),
(1028,7,'2026-05-19 19:45:00','DELIVERED',3,0),
(1029,10,'2026-06-30 12:55:00','SHIPPED',NULL,3000),
(1030,3,'2026-08-11 17:40:00','PAID',NULL,3000);

INSERT INTO order_items (order_id,product_id,qty,unit_price) VALUES
(1001,201,2,24000),(1001,204,1,19000),
(1002,101,1,39000),
(1003,301,1,1290000),
(1004,202,1,32000),(1004,203,1,45000),
(1005,403,2,22000),
(1006,302,1,2450000),
(1007,201,3,24000),(1007,202,2,30000),(1007,203,1,45000),
(1008,304,1,189000),
(1009,301,1,1290000),(1009,304,1,189000),
(1010,401,1,26000),
(1011,102,1,59000),
(1012,403,1,22000),(1012,401,2,28000),
(1013,104,1,62000),
(1014,302,1,2450000),
(1015,201,1,24000),(1015,204,2,21000),
(1016,402,1,59000),
(1017,203,1,45000),
(1018,205,1,38000),(1018,204,1,21000),(1018,202,1,32000),
(1019,101,2,39000),
(1020,201,1,24000),
(1021,305,1,259000),(1021,304,2,189000),
(1022,401,1,28000),(1022,403,1,22000),(1022,402,1,59000),
(1023,303,1,890000),
(1024,202,2,32000),(1024,304,1,189000),
(1025,204,1,21000),(1025,201,1,24000),
(1026,303,1,890000),(1026,104,1,62000),
(1027,102,1,59000),(1027,101,1,39000),
(1028,305,1,259000),
(1029,401,2,28000),
(1030,104,1,62000),(1030,102,1,59000);

-- 결제 데이터는 주문 내역에서 계산해 생성 (취소 주문은 결제 행 없음)
INSERT INTO payments (order_id, method, amount, paid_at, refunded_at)
SELECT o.order_id,
ELT(o.order_id % 4 + 1,'CARD','KAKAOPAY','NAVERPAY','BANK'),
t.goods
- CASE WHEN c.coupon_id IS NULL OR t.goods < c.min_amount THEN 0 WHEN c.discount_type='RATE' THEN FLOOR(t.goods * c.discount_value / 100) ELSE c.discount_value END + o.ship_fee, o.ordered_at + INTERVAL 2 MINUTE, CASE WHEN o.status='REFUNDED' THEN o.ordered_at + INTERVAL 5 DAY END FROM orders o JOIN (SELECT order_id, SUM(qty * unit_price) AS goods FROM order_items GROUP BY order_id) t ON t.order_id=o.order_id LEFT JOIN coupons c ON c.coupon_id=o.coupon_id WHERE o.status <> 'CANCELLED';

  INSERT INTO reviews VALUES
  (1,201,1,5,'자극 없고 순해요','2025-03-12'),
  (2,204,1,3,'색은 예쁜데 지속력이 아쉬움','2025-03-14'),
  (3,101,2,4,'핏이 좋아요','2025-03-20'),
  (4,202,1,5,'재구매합니다','2025-04-25'),
  (5,403,4,4,'아침 대용으로 굿','2025-05-15'),
  (6,201,2,5,'용량 대비 가격 만족','2025-06-08'),
  (7,203,2,2,'저한테는 트러블이 났어요','2025-06-10'),
  (8,304,6,4,'통화 품질 준수','2025-06-22'),
  (9,301,7,5,'가볍고 빠릅니다','2025-07-03'),
  (10,401,1,3,'크기가 생각보다 작아요','2025-07-10'),
  (11,403,3,5,'달지 않아 좋아요','2025-08-10'),
  (12,104,5,4,'보풀이 조금 있음','2025-09-01'),
  (13,302,7,5,'작업용으로 최고','2025-09-15'),
  (14,201,9,4,'무난합니다','2025-10-02'),
  (15,204,9,1,'발색이 사진과 달라요','2025-10-05'),
  (16,203,4,3,'보통','2025-11-05'),
  (17,205,1,4,'커버력 좋아요','2025-11-20'),
  (18,101,6,5,'색상 추가 구매','2025-12-03'),
  (19,201,10,5,'순하고 좋아요','2025-12-12'),
  (20,202,2,4,'무난','2026-02-12'),
  (21,303,1,5,'배터리 오래감','2026-03-20'),
  (22,305,7,4,'음질 만족','2026-05-25'),
  (23,203,1,4,'순한 편이에요','2025-05-01'),
  (24,204,11,4,'데일리로 좋아요','2026-04-10'),
  (25,101,8,2,'사이즈가 커요','2026-04-15'),
  (26,403,5,5,'재구매 3번째','2026-01-20'),
  (27,304,7,5,'노이즈캔슬링 굿','2026-01-05'),
  (28,302,11,4,'매장에서 써보고 남깁니다','2026-03-01');

  -- 사후 환불인데 주문 상태가 갱신되지 않은 케이스 (Q70용)
  UPDATE payments SET refunded_at = '2025-11-20 10:00:00' WHERE order_id = 1017;
  
  #5·49·66·79·80번은 오늘 날짜에 따라 정답이 바뀝니다. 오늘 날짜를 '2026-09-08' 로 설정해주세요
  
  ### A. 워밍업 (1~10)

--   1. 판매 중인 상품(단종되지 않은 상품)의 상품명과 가격을 가격 높은 순으로 조회하시오.
select product_name, price
from products
order by price desc;
--   2. 각 상품의 마진율(`(price-cost)/price`)을 % 소수 1자리로 조회하시오. 마진율 60% 이상만.
select *
from products;
select product_name, round((price-cost)/price, 1) as 마진율
from products
where (price-cost)/price >= 0.6;

--   3. 회원 등급별 회원 수를 조회하되, BRONZE→SILVER→GOLD→VIP 순으로 정렬하시오. (`FIELD()` 또는 CASE)
select count(*), grade
from members
group by grade
order by field(grade, 'BRONZE', 'SILVER', 'GOLD', 'VIP'),grade;

--   4. 이메일이 없는 회원, 생년월일이 없는 회원을 각각 조회하시오.
select *
from members;
select name as '이메일이 없는 회원', (select name from members where birth_date is null) as '생년월일이 없는 회원'
from members
where email is null;

--   5. 회원의 나이를 `@today` 기준으로 계산해 조회하시오. 생일이 아직 안 지났으면 한 살 적게 나와야 한다.
select name, round(DATEDIFF('2026-09-08', birth_date)/365) as '나이'
from members;

--   6. 2025년에 들어온 주문 건수를 월별로 조회하시오.
select substr(ordered_at, 1, 7) as month, count(*)
from orders
where ordered_at like '2025%'
group by month;

--   7. 주문 상태별 건수와 전체 대비 비율(%)을 조회하시오.
select status, count(status), count(status) * 1 / (select count(*) from orders)  as '비율'
from orders
group by status;

--   8. 재고가 0인 상품을 조회하고, 단종(discontinued_at 있음) 인지 품절(단종은 아닌데 재고 0) 인지 구분 컬럼을 붙이시오.
select product_name, if (discontinued_at is null, '품절', '단종') as '단종 여부'
from products
where stock = 0;

--   9. 상품명에 용량 표기(숫자+ml 또는 숫자+g/kg)가 들어간 상품만 조회하시오. (LIKE 또는 REGEXP)
select *
from products
where product_name like '%kg%' or product_name like '%ml%' or product_name like '%g%' or product_name like '%l%';

--   10. 주문 일시에서 시간대(0~23시)만 뽑아, 시간대별 주문 건수를 조회하시오. 주문이 가장 몰리는 시간대는?
select substr(ordered_at , 11, 3) as hour, count(*) 
from orders
group by hour
order by count(*) desc;

--   ### B. 조인 (11~22)
-- 
--   11. 주문번호, 주문일, 주문자 이름, 주문자 등급을 조회하시오.
select o.order_id, o.ordered_at, m.name, m.grade
from orders as o
inner join members as m
on o.member_id = m.member_id;

--   12. 주문 상품 상세(주문번호, 상품명, 수량, 단가, 금액=수량×단가)를 조회하시오.
select o.order_id, p.product_name, o.qty, p.price, p.price * o.qty as '금액'
from order_items as o
inner join products as p
on o.product_id = p.product_id
order by o.order_id asc;

--   13. 주문번호별 총 상품금액과 상품 종류 수를 조회하시오.
select o.order_id, p.price * o.qty as '총 금액', count(p.product_name) as '상품 종류 수'
from order_items as o
inner join products as p
on o.product_id = p.product_id
group by o.order_id
order by o.order_id asc;
--   14. 한 번도 주문되지 않은 상품 을 조회하시오.
select *
from order_items as o
inner join products as p
on o.product_id = p.product_id
group by o.product_id
having count(o.product_id) = 0;

select *
from members;
--   15. 주문 이력이 전혀 없는 회원 을 조회하시오.
select *
from orders as o
inner join members as m
on o.member_id = m.member_id
group by o.member_id;

--   16. 리뷰가 하나도 없는 상품을 판매사 이름과 함께 조회하시오.
--   17. 결제 정보가 없는 주문을 찾아내시오. 이런 주문이 존재하는 이유는?
--   18. 상품별 판매수량과 판매금액을 조회하되, 취소·환불된 주문은 제외하시오.
--   19. 판매사별 매출액과, 거기서 플랫폼이 떼가는 수수료 (`매출 × commission_rate`)를 조회하시오.
--   20. 상품의 대분류 카테고리명 을 함께 조회하시오. (예: 토너 → 뷰티) 카테고리는 최대 3단계다.
--   21. 각 회원의 추천인 이름을 함께 조회하시오. 추천인이 없는 회원도 나와야 한다.
--   22. 추천인 역할을 한 회원별로, 자기가 추천한 회원 수와 그 회원들의 총 구매액을 조회하시오.
-- 
--   ### C. 집계·그룹핑 (23~34)
-- 
--   23. 회원별 총 주문건수, 총 결제금액, 평균 주문금액을 조회하시오. (환불 건 제외)
--   24. 회원 등급별 평균 결제금액을 구하고, 전체 평균보다 높은 등급만 조회하시오.
--   25. 월별 매출(결제금액 합계)을 조회하고, 매출이 100만원 이상인 달만 출력하시오.
--   26. 2단계 카테고리 기준 으로 판매수량 TOP 5를 조회하시오. 단, 3단계 카테고리(토너·크림)에 속한 상품은 상위 2단계(스킨케어)로 올려서 집계할 것.
--   27. 상품별 평균 평점과 리뷰 수를 조회하되, 리뷰 3건 이상인 상품만 평균 평점 순으로 정렬하시오.
--   28. 도시별 회원 수와 평균 구매액을 조회하시오. 구매 이력 없는 도시도 0으로 나와야 한다.
--   29. 결제수단별 결제건수와 평균 결제금액을 조회하시오.
--   30. 쿠폰별 사용 횟수와 실제 할인된 총액을 조회하시오. 한 번도 안 쓰인 쿠폰도 0으로 출력할 것.
--   31. 판매사별로 최고가 상품과 최저가 상품 이름을 한 행에 나란히 출력하시오.
--   32. 회원별 첫 주문일과 마지막 주문일, 그 간격(일)을 조회하시오.
--   33. 연도-분기별 매출을 조회하고 `WITH ROLLUP`으로 연간 합계·전체 합계까지 붙이시오.
--   34. 상품별 구매 회원 이름을 콤마로 이어 한 컬럼에 출력하시오. (구매 수량 많은 순으로 정렬)
-- 
--   ### D. 서브쿼리 (35~45)
-- 
--   35. 전체 평균 결제금액보다 큰 주문을 조회하시오.
--   36. 자기 등급의 평균 구매액보다 많이 쓴 회원을 조회하시오. (상관 서브쿼리)
--   37. 35~36번을 인라인 뷰 조인으로 다시 작성하시오.
--   38. '수분 진정 토너 500ml'를 산 사람이 같이 산 다른 상품 을 판매수량 순으로 조회하시오.
--   39. 리뷰를 한 번도 쓰지 않은 구매 회원을 조회하시오. (EXISTS / NOT EXISTS)
--   40. 39번을 `NOT IN`으로 작성했을 때 주의할 점은? (서브쿼리 결과에 NULL이 섞이는 상황을 가정해 설명)
--   41. 자기가 리뷰를 남긴 상품을 실제로 구매한 적이 없는 회원이 있는지 확인하시오. (데이터 정합성 검증 — 위반 건이 존재한다 )
--   42. 가장 비싼 상품을 파는 판매사의 모든 상품을 조회하시오.
--   43. 모든 대분류 카테고리(패션/뷰티/디지털/식품)에서 최소 1건 이상 구매한 회원을 조회하시오. (관계 나눗셈)
--   44. 결제금액이 해당 회원의 평균 결제금액의 2배를 넘는 주문(이상치 후보)을 조회하시오.
--   45. `products.price`와 실제 판매된 `unit_price`가 다른 주문 항목을 찾아, 차액과 함께 조회하시오. 왜 이런 컬럼 설계를 하는지 설명하시오.
-- 
--   ### E. 윈도우 함수 (46~57)
-- 
--   46. 회원별 총 구매액 순위를 매기시오. `RANK / DENSE_RANK / ROW_NUMBER` 차이가 드러나게.
--   47. 카테고리별 매출 TOP 2 상품을 조회하시오.
--   48. 각 회원의 주문을 시간순으로 번호 매기고, 직전 주문과의 간격(일) 을 조회하시오. (LAG)
--   49. 48번을 이용해 회원별 평균 재구매 주기를 구하고, 주기가 가장 짧은 회원 3명을 조회하시오.
--   50. 월별 매출과 전월 대비 증감률(%) 을 조회하시오.
--   51. 월별 매출의 누적합(YTD)을 연도별로 리셋되게 조회하시오.
--   52. 주문 금액 기준 상위 20% 주문만 조회하시오. (NTILE 또는 PERCENT_RANK)
--   53. 각 주문 항목이 그 주문 전체 금액에서 차지하는 비중(%)을 조회하시오.
--   54. 회원별 누적 구매액 을 계산하고, 누적 100만원 을 처음 넘긴 주문을 회원별로 하나씩 찾으시오.
--   55. 상품별 리뷰를 시간순으로 정렬해, 각 리뷰 시점까지의 누적 평균 평점 을 조회하시오.
--   56. 매출 상위 회원부터 누적 매출 비중을 계산해, 누적 80%를 차지하는 회원(파레토) 을 조회하시오.
--   57. 각 회원의 첫 구매 상품명과 마지막 구매 상품명을 한 행에 출력하시오. 한 주문에 상품이 여러 개면 `order_item_id` 오름차순을 우선순위로 할 것. (FIRST_VALUE / LAST_VALUE — 프레임 지정 주의)
-- 
--   ### F. CTE·재귀·피벗 (58~66)
-- 
--   58. 재귀 CTE로 카테고리 전체 계층을 `패션 > 여성의류` 형태의 경로로 출력하시오. (레벨 포함)
--   59. 대분류 '뷰티' 하위의 모든 하위 카테고리 (손자까지)에 속한 상품을 조회하시오.
--   60. 재귀 CTE로 추천인 체인을 따라가, 각 회원의 최상위 추천인 과 체인 깊이를 구하시오.
--   61. 재귀 CTE로 2025-01 ~ 2026-08 월 목록을 만들고, 주문이 0건인 달도 0으로 나오는 월별 매출표를 만드시오.
--   62. 회원 등급을 행, 대분류 카테고리를 열로 하는 구매금액 피벗 테이블을 만드시오.
--   63. 요일을 행, 시간대(오전/오후/저녁/심야)를 열로 하는 주문건수 피벗을 만드시오.
--   64. CTE 여러 개를 체이닝해서 "월별 신규회원 수 / 주문회원 수 / 매출"을 한 표로 만드시오.
--   65. 가입 연도별 코호트 재구매율 을 구하시오. (가입 연도 그룹 × 주문 2회 이상 비율)
--   66. RFM 분석: 회원별 Recency(마지막 주문 경과일), Frequency(주문수), Monetary(총액)를 구하고 각각 1~4점으로 점수화한 뒤, RFM 등급을 부여하시오.
-- 
--   ### G. 데이터 품질·함정 (67~74)
-- 
-- 67. `SELECT COUNT(*), COUNT(coupon_id), COUNT(DISTINCT coupon_id) FROM orders;` 결과가 왜 다른지 설명하시오.
-- 68. 배송비를 포함한 주문 총액을 `SUM(qty*unit_price) + ship_fee` 로 구하면 틀린다. 왜인지 설명하고 고치시오.
-- 69. 취소 주문을 빼야 하는데 `WHERE status != 'CANCELLED'` 만 쓰면 놓치는 케이스가 무엇인지 검토하시오. 매출 정의를 세 가지로 나눠 각각 쿼리를 작성하시오.
-- 70. `payments.refunded_at IS NULL` 로 정상결제를 거르는 것과 `orders.status <> 'REFUNDED'` 로 거르는 것의 결과를 비교하시오. 건수가 다르다 — 어느 주문 때문이고, 실무에서는 어느 쪽을 신뢰해야 하는가?
-- 71. 회원별 주문수를 `LEFT JOIN + COUNT(*)` 로 구하면 주문 없는 회원이 1로 나온다. 이유와 해결책은?
-- 72. `orders o JOIN order_items oi JOIN payments p` 로 조인한 뒤 `SUM(p.amount)` 를 구하면 값이 부풀려진다. 팬아웃(fan-out) 현상을 설명하고 올바른 쿼리를 작성하시오.
-- 73. 생년월일이 NULL인 회원이 섞인 상태에서 `AVG(age)` 와 `SUM(age)/COUNT(*)` 의 차이를 확인하시오.
-- 74. `WHERE DATE(ordered_at) = '2025-03-05'` 와 `WHERE ordered_at >= '2025-03-05' AND ordered_at < '2025-03-06' ` 의 실행계획 차이를 `EXPLAIN`으로 비교하시오. (`ordered_at`에 인덱스 추가 후 재확인)
### H. 종합 과제 (75~80) 75. 상품 성적표 : 상품명, 카테고리 경로, 판매사, 총 판매수량, 총 매출, 마진, 평균 평점, 리뷰 수, 카테고리 내 매출 순위를 한 표로. 판매 이력 없는 상품도 0으로 포함. 76. 회원 대시보드 : 회원명, 등급, 가입 후 경과일, 주문수, 총결제액, 평균 주문액, 마지막 주문 경과일, 최애 카테고리(가장 많이 산 대분류), 추천으로 데려온 인원. 77. 월간 리포트 : 월별 매출·주문수·객단가·신규회원수·재구매율을 한 표로, 전월 대비 증감률 포함. 78. 쿠폰 효과 분석 : 쿠폰 사용 주문 vs 미사용 주문의 평균 주문금액·평균 상품수를 비교하고, 쿠폰이 객단가를 올렸는지 판단하시오. (주의: 쿠폰이 붙었어도 `min_amount` 미달로 실제 할인이 0원인 주문이 있다) 79. 이탈 위험 회원 : 과거 2회 이상 구매했으나 마지막 주문이 180일 이상 지난 회원을, 총 구매액 순으로 조회하시오. 80. 재고 경고 : 최근 180일 판매 속도(일 평균 판매수량) 기준으로 예상 소진일을 계산하고, 30일 내 품절 예상 상품을 조회하시오.
