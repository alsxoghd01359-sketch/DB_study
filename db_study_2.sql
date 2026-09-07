# a6 DB 삭제/생성/선택
drop database if exists `a6`;
create database `a6`;
use `a6`;
# 부서(홍보, 기획)
create table dept(
	id int(100) PRIMARY KEY AUTO_INCREMENT,
	name varchar(100) not null
);

desc dept;

insert into dept
set name = '홍보';
insert into dept
set name = '기획';

select *
from dept;

# 사원(홍길동/홍보/5000만원, 홍길순/홍보/6000만원, 임꺽정/기획/4000만원)
create table emp(
	id int(100) PRIMARY KEY AUTO_INCREMENT,
	name varchar(100) not null,
	dept_id int(100) not null,
	salary int not null
);

insert into emp
set name = '홍길동', dept_id = '1', salary = '50000000';
insert into emp
set name = '홍길순', dept_id = '1', salary = '60000000';
insert into emp
set name = '임꺽정', dept_id = '2', salary = '40000000';

desc emp;
select *
from emp;

# 사원 수 출력
select count(*)
from emp;

# 가장 큰 사원 번호 출력
select max(id)
from emp;

# 가장 고액 연봉
select max(salary)
from emp;

# 가장 저액 연봉
select min(salary)
from emp;

# 회사에서 1년 고정 지출(인건비)
select sum(salary)
from emp;

# 부서별, 1년 고정 지출(인건비)
select *
from emp;
select *
from dept;
select dept_id, sum(salary)
from emp
group by dept_id;

## join 사용
select d.name, sum(e.salary)
from dept as d inner join emp as e
on d.id = e.dept_id
group by d.id;

# 부서별, 최고연봉
select dept_id, max(salary)
from emp
group by dept_id;

select *
from dept;



## join 사용
select d.name, max(e.salary)
from dept as d inner join emp as e
on d.id = e.dept_id
group by d.id;

# 부서별, 최저연봉
select dept_id, min(salary)
from emp
group by dept_id;

select *
from dept;

## join 사용
select d.name, min(e.salary)
from dept as d inner join emp as e
on d.id = e.dept_id
group by d.id;

# 부서별, 평균연봉
select dept_id, avg(salary)
from emp
group by dept_id;

select *
from dept;



## join 사용
select d.name, avg(e.salary)
from dept as d inner join emp as e
on d.id = e.dept_id
group by d.id;

# 부서별, 부서명, 사원리스트, 평균연봉, 최고연봉, 최소연봉, 사원수 
## V1(조인 안한 버전)
select d.name, group_concat(e.name), avg(e.salary), max(e.salary), min(e.salary), count(e.id)
from emp as e, dept as d
where e.dept_id = d.id
group by e.dept_id;

## V2(조인해서 부서명까지 나오는 버전)
select d.name, group_concat(e.name), avg(e.salary), max(e.salary), min(e.salary), count(e.id)
from dept as d inner join emp as e
on d.id = e.dept_id
group by d.id;

## V3(V2에서 평균연봉이 5000이상인 부서로 추리기)
select d.name, group_concat(e.name), avg(e.salary), max(e.salary), min(e.salary), count(e.id)
from dept as d inner join emp as e
on d.id = e.dept_id
group by d.id
having avg(e.salary) >= 50000000;
