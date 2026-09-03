# 전체 데이터베이스 리스팅
show databases;
# `mysql` 데이터 베이스 선택
use `mysql`;
# 테이블 리스팅
show tables;
# 특정 테이블의 구조
desc event;
# `test` 데이터 베이스 선택
use `test`;
# 테이블 리스팅
show tables;
# 기존에 a1 데이터베이스가 존재 한다면 삭제
drop database if exists `a1`;
# 새 데이터베이스(`a1`) 생성
create database `a1`;
# 데이터베이스(`a1`) 선택
use `a1`;
# 데이터베이스 추가 되었는지 확인
show databases;
# 테이블 확인
show tables;
# 게시물 테이블 article(title, body)을 만듭니다.
# VARCHAR(100) => 문자 100개 저장가능
# text => 문자 많이 저장가능
create table article(
	title VARCHAR(100),
	body text
);
# 잘 추가되었는지 확인, 리스팅과 구조까지 확인
show tables;
desc article;
# 데이터 하나 추가(title = 제목, body = 내용)
insert into article
set title = '제목', body = '내용';
# 데이터 조회(title 만)
select title
from article;
# 데이터 조회(title, body)
select title, body
from article;
# 데이터 조회(body, title)
select body, title
from article;
# 데이터 조회(*)
select *
from article;
# 데이터 또 하나 추가(title = 제목, body = 내용)
insert into article
set title = '제목', body = '내용';
# 데이터 조회(*, 어떤게 2번 게시물인지 알 수 없음)
select *
from article;
# 테이블 구조 수정(id 칼럼 추가, first)
alter table article add column id int(10) first;
# 데이터 조회(*, id 칼럼의 값은 NULL)
select *
from article;
# 기존 데이터에 id값 추가(id = 1, id IS NULL)
update article
set id = 1;
# 데이터 조회(*, 둘다 수정되어 버림..)
select *
from article;
# 기존 데이터 중 1개만 id를 2로 변경(LIMIT 1)
update article
set id = 2 limit 1;
# 데이터 조회(*)
select *
from article;
# 데이터 1개 추가(id = 3, title = 제목3, body = 내용3)
insert into article
set id = 3, title = '제목3', body = '내용3';
# 데이터 조회(*)
select *
from article;
# 2번 게시물, 데이터 삭제 => DELETE
delete from article 
where id = 2;
# 데이터 조회(*)
select *
from article;
# 날짜 칼럼 추가 => regDate DATETIME
alter table article add column regDate DATETIME;
# 테이블 구조 확인
desc article;
# 데이터 조회(*, 날짜 정보가 비어있음)
select *
from article;
# 1번 게시물의 비어있는 날짜정보 채움(regDate = 2018-08-10 15:00:00)
update article
set regDate = '2018-08-10 15:00:00'
where id = 1;
# 데이터 조회(*, 이제 2번 게시물의 날짜 정보만 넣으면 됩니다.)
select *
from article;
# NOW() 함수 실행해보기
select now();
# 3번 게시물의 비어있는 날짜정보 채움(NOW())
update article
set regDate = NOW()
where id = 3;
# 데이터 조회(*)
select *
from article;


# 기존에 a2 데이터베이스가 존재 한다면 삭제
drop database if exists `a2`;
# 새 데이터베이스(`a2`) 생성
create database `a2`;
# 새 데이터베이스(`a2`) 선택
use `a2`;
# article 테이블 생성(id, regDate, title, body)
create table article(
	id int(10),
	regDate datetime,
	title VARCHAR(100),
	body text
);

# article 테이블 조회(*)
select *
from article;
# article 테이블에 data insert (regDate = NOW(), title = '제목', body = '내용')
insert into article
set regDate = NOW(), title = '제목', body = '내용';
# article 테이블에 data insert (regDate = NOW(), title = '제목', body = '내용')
insert into article
set regDate = NOW(), title = '제목', body = '내용';
# article 테이블 조회(*)
## id가 NULL인 데이터 생성이 가능하네?
select *
from article;
# id 데이터는 꼭 필수 이기 때문에 NULL을 허용하지 않게 바꾼다.(alter table, not null)
## 기존의 NULL값 때문에 경고가 뜬다.
## 기존의 NULL값이 0으로 바뀐다.
update article
set id = 0;

alter table article modify column id int(10) not null;
# article 테이블 조회(*)
select *
from article;
# 생각해 보니 모든 행(row)의 id 값은 유니크 해야한다.(ADD PRIMARY KEY(id))
## 오류가 난다. 왜냐하면 기존의 데이터 중에서 중복되는게 있기 때문에
alter table article ADD PRIMARY KEY(id);
# id가 0인 것 중에서 1개를 id 1로 바꾼다.
update article
set id = 1 limit 1;
# article 테이블 조회(*)
select *
from article;
# id가 0인것을 id 2로 바꾼다.
update article
set id = 2 where id = 1;
# 생각해 보니 모든 행(row)의 id 값은 유니크 해야한다.(ADD PRIMARY KEY(id))
## 이제 적용이 잘 된다.
alter table article ADD PRIMARY KEY(id);
# id 칼럼에 auto_increment 를 건다.
## auto_increment 를 걸기전에 해당 칼럼은 무조건 key 여야 한다.
alter table article modify column id int(10) auto_increment;
# article 테이블 구조확인(desc)
desc article;
# 나머지 칼럼 모두에도 not null을 적용해주세요.
alter table article modify column regDate datetime not null;
alter table article modify column title VARCHAR(100) not null;
alter table article modify column body text not null;
# id 칼럼에 UNSIGNED 속성을 추가하세요.
alter table article modify column id int(10) UNSIGNED;
# 작성자(writer) 칼럼을 title 칼럼 다음에 추가해주세요.
alter table article add column writer VARCHAR(30) first;
# 작성자(writer) 칼럼의 이름을 nickname 으로 변경해주세요.(ALTER TABLE article CHANGE oldName newName TYPE 조건)
alter table article change writer nickname VARCHAR(30);
# nickname 칼럼의 위치를 body 밑으로 보내주세요.(MODIFY COLUMN nickname)
alter table article modify column nickname VARCHAR(30) after body;

select *
from article;

# hit 조회수 칼럼 추가 한 후 삭제해주세요.
alter table article add column hit int not null;
# hit 조회수 칼럼을 다시 추가
alter table article drop column hit;
alter table article add column hit int not null;
# 기존의 비어있는 닉네임 채워넣기(무명)
update article
set nickname = '무명';
# article 테이블에 데이터 추가(regDate = NOW(), title = '제목3', body = '내용3', nickname = '홍길순', hit = 10)
insert into article set regDate = NOW(), title = '제목3', body = '내용3', nickname = '홍길순', hit = 10;
insert into article set regDate = NOW(), title = '제목4', body = '내용4', nickname = '홍길동', hit = 55;
insert into article set regDate = NOW(), title = '제목5', body = '내용5', nickname = '홍길동', hit = 10;
insert into article set regDate = NOW(), title = '제목6', body = '내용6', nickname = '임꺽정', hit = 100;

select *
from article;

# article 테이블에 데이터 추가(regDate = NOW(), title = '제목4', body = '내용4', nickname = '홍길동', hit = 55)

# article 테이블에 데이터 추가(regDate = NOW(), title = '제목5', body = '내용5', nickname = '홍길동', hit = 10)

# article 테이블에 데이터 추가(regDate = NOW(), title = '제목6', body = '내용6', nickname = '임꺽정', hit = 100)

# 조회수 가장 많은 게시물 3개 만 보여주세요., 힌트 : ORDER BY, LIMIT
select *
from article
order by hit desc limit 3;
# 작성자명이 '홍길'로 시작하는 게시물만 보여주세요., 힌트 : LIKE '홍길%'
select *
from article
where nickname like '홍길%';
# 조회수가 10 이상 55 이하 인것만 보여주세요., 힌트 : WHERE 조건1 AND 조건2
select *
from article
where hit >= 10 and hit <= 55;
# 작성자가 '무명'이 아니고 조회수가 50 이하인 것만 보여주세요., 힌트 : !=
select *
from article
where nickname != '무명' and hit <= 50;
# 작성자가 '무명' 이거나 조회수가 55 이상인 게시물을 보여주세요. 힌트 : OR
select *
from article
where nickname = '무명' or hit >= 55;
