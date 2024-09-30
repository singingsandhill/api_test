CREATE DATABASE user_info;
USE user_info;
CREATE TABLE user_info (
    uid INT NOT NULL PRIMARY KEY,                    -- 유저 관리번호
    id VARCHAR(50) NOT NULL,                         -- 아이디
    password VARCHAR(100) NOT NULL,                  -- 비밀번호
    email VARCHAR(100) NOT NULL,                     -- 이메일
    social VARCHAR(10) NOT NULL,                     -- 가입 유형
    birth_year INT NOT NULL,                         -- 생년
    gender CHAR(1) NOT NULL,                         -- 성별 (F or M)
    mobile VARCHAR(15),                              -- 핸드폰번호 (INT에서 VARCHAR로 변경, 국제번호 포함 가능성)
    profile VARCHAR(255),                            -- 프로필 이미지 경로
    agreement_info BOOLEAN NOT NULL ,    			-- 동의여부_정보
    agreement_finace BOOLEAN NOT NULL 				-- 동의여부_활용
);
CREATE TABLE user_api (
    uid INT NOT NULL PRIMARY KEY,                     -- 유저 관리번호
    api_bank VARCHAR(255),                            -- 은행권 API Key
    api_stock VARCHAR(255),                           -- 증권계좌 API Key
    api_stock_token VARCHAR(255),                     -- 증권계좌 API Token
    api_stock_secret VARCHAR(255),                    -- 증권계좌 App Key
    api_stock_app VARCHAR(255),                       -- 증권계좌 App Secret
    api_coin VARCHAR(255),                            -- 코인계좌 API Key
    api_coin_app VARCHAR(255),                        -- 코인계좌 App Key
    api_coin_secret VARCHAR(255)                      -- 코인계좌 App Secret
);
CREATE TABLE user_badge (
    uid INT NOT NULL,                                -- 유저 관리번호
    badg_no INT NOT NULL,                            -- 배지 번호
    badg VARCHAR(100),                               -- 배지 이름
    badge_achive BOOLEAN DEFAULT FALSE,              -- 획득 여부
    PRIMARY KEY (uid, badg_no)                       -- 유저 관리번호와 배지 번호의 복합 기본키 설정
);
CREATE TABLE user_goal (
	`index` INT AUTO_INCREMENT PRIMARY KEY,
    UID INT NOT NULL,                            -- 유저 관리번호
    category VARCHAR(50),                        -- 자산/소비 목표 구분
    title VARCHAR(1000),                         -- 목표 이름
    amount BIGINT                               -- 목표 금액
);
ALTER TABLE user_badge ADD COLUMN badge_main boolean default false;
ALTER TABLE user_info ADD COLUMN is_mento boolean default false;
ALTER TABLE user_info drop COLUMN mobile;
ALTER TABLE user_info ADD COLUMN nickname varchar(50);
UPDATE user_info SET nickname = id;
ALTER TABLE user_info RENAME COLUMN is_mento TO is_mentor;
ALTER TABLE user_badge RENAME COLUMN badg_no TO badge_no;
ALTER TABLE user_badge RENAME COLUMN badg TO badge;
ALTER TABLE user_info ADD COLUMN is_certification boolean default false;
alter table user_info MODIFY COLUMN is_mento boolean;
ALTER TABLE user_goal ADD COLUMN set_date timestamp not null;
UPDATE user_goal SET set_date = '2024-09-19 13:03:39';
ALTER TABLE user_goal MODIFY COLUMN is_achive tinyint(1) not null default false;

############################################################################################################
CREATE DATABASE master;
USE master;
CREATE TABLE badge (
    badg_no INT NOT NULL PRIMARY KEY,               -- 배지 번호
    badge VARCHAR(100) NOT NULL,                    -- 배지 이름
    image VARCHAR(255) NOT NULL,                    -- 이미지 경로
    description VARCHAR(255)                        -- 설명
);
CREATE TABLE api (
    `index` INT NOT NULL PRIMARY KEY,               -- 색인 번호 (Primary Key)
    open_api VARCHAR(255),                        -- 공공데이터 포탈 접속 key
    deposit_key VARCHAR(255),                     -- 금융감독원 적금 key
    saving_key VARCHAR(255)                       -- 금융감독원 예금 key
);
ALTER TABLE api RENAME COLUMN deposit_key TO deposite_key;

#################################################################
CREATE DATABASE asset;
use asset;
CREATE TABLE coin (
`index` INT AUTO_INCREMENT PRIMARY KEY,
uid int NOT NULL,
currency VARCHAR(10) NOT NULL,
balance DOUBLE NOT NULL,
avg_buy_price DOUBLE NOT NULL,
unit_currency VARCHAR(10) NOT NULL
 );
ALTER TABLE coin MODIFY COLUMN  uid int NOT NULL;
ALTER TABLE coin ADD COLUMN prod_name VARCHAR(100);
ALTER TABLE coin RENAME COLUMN prod_name TO prod_category;
UPDATE coin SET prod_name = 'coin';

CREATE TABLE stock (
    `index` INT NOT NULL PRIMARY KEY,               -- 색인 번호 (Primary Key)
    uid INT NOT NULL,                             -- 유저 관리번호
    pdno INT NOT NULL,                            -- 종목번호 (상품번호)
    prdt_name VARCHAR(100) NOT NULL,              -- 종목명 (상품명)
    hldg_qty INT NOT NULL                        -- 보유수량
);
ALTER TABLE stock ADD COLUMN prod_name VARCHAR(100);
UPDATE stock SET prod_name = 'stock';
ALTER TABLE stock RENAME COLUMN prod_name TO prod_category;

CREATE TABLE bank (
    `index` INT NOT NULL PRIMARY KEY,               -- 색인 번호 (Primary Key)
    uid INT NOT NULL,                             -- 유저 관리번호
    org_code VARCHAR(100) NOT NULL,               -- 기관코드 (은행명)
    account_num BIGINT NOT NULL,                  -- 계좌번호
    prod_name VARCHAR(100) NOT NULL,              -- 상품명
    prod_category VARCHAR(100) NOT NULL,          -- 상품 카테고리
    account_type VARCHAR(100),                    -- 계좌구분 (코드)
    currency_code VARCHAR(10),                    -- 통화코드
    balance_amt BIGINT NOT NULL                   -- 현재 잔액
);
ALTER TABLE bank MODIFY COLUMN  org_code VARCHAR(100) NULL;
-- ALTER TABLE bank MODIFY COLUMN  prod_name VARCHAR(100) NULL;
ALTER TABLE bank MODIFY COLUMN  account_num BIGINT NULL;
-- ALTER TABLE bank RENAME COLUMN prod_name TO prod_category;

CREATE TABLE spot (
    `index` INT NOT NULL PRIMARY KEY,               -- 색인 (Primary Key)
    uid INT NOT NULL,                             -- 유저 관리번호
    category VARCHAR(20) NOT NULL,                -- 분류명
    name VARCHAR(50) NOT NULL,                    -- 자산명
    price BIGINT NOT NULL                         -- 가격
);
ALTER TABLE spot ADD COLUMN prod_name VARCHAR(100);
UPDATE spot SET prod_name = 'spot';
ALTER TABLE spot RENAME COLUMN prod_name TO prod_category;

CREATE TABLE bond (
    `index` INT NOT NULL PRIMARY KEY,               -- 색인 (Primary Key)
    uid INT NOT NULL,                             -- 관리번호 (유저 관리번호)
    itms_nm VARCHAR(255) NOT NULL,                -- 종목명
    cnt INT NOT NULL                              -- 수량
);
ALTER TABLE bond ADD COLUMN prod_name VARCHAR(100);
UPDATE bond SET prod_name = 'bond';
ALTER TABLE bond ADD COLUMN per_price int;
UPDATE bond SET per_price = 100000;
ALTER TABLE bond RENAME COLUMN prod_name TO prod_category;

CREATE TABLE income (
    `index` INT NOT NULL PRIMARY KEY,               -- 색인 (Primary Key)
    uid INT NOT NULL,                             -- 관리번호 (유저 관리번호)
    type VARCHAR(100) NOT NULL,                   -- 구분 (월급, 비정기 소득 구분)
    amount BIGINT NOT NULL                        -- 금액 (0값은 초기 값 UID당)
);
ALTER TABLE bank ADD COLUMN add_date timestamp not null;
UPDATE bank SET add_date = '2024-09-19 13:03:39';
ALTER TABLE bank ADD COLUMN delete_date DATETIME DEFAULT '2999-12-31 00:00:00' NOT NULL;
ALTER TABLE bond ADD COLUMN add_date timestamp not null;
UPDATE bond SET add_date = '2024-09-19 13:03:39';
ALTER TABLE bond ADD COLUMN delete_date DATETIME default '2999-12-31 00:00:00' not null;
ALTER TABLE coin ADD COLUMN add_date timestamp not null;
UPDATE coin SET add_date = '2024-09-19 13:03:39';
ALTER TABLE coin ADD COLUMN delete_date DATETIME default '2999-12-31 00:00:00' not null;
ALTER TABLE spot ADD COLUMN add_date timestamp not null;
UPDATE spot SET add_date = '2024-09-19 13:03:39';
ALTER TABLE spot ADD COLUMN delete_date DATETIME default '2999-12-31 00:00:00' not null;
ALTER TABLE stock ADD COLUMN add_date timestamp not null;
UPDATE stock SET add_date = '2024-09-19 13:03:39';
ALTER TABLE stock ADD COLUMN delete_date DATETIME default '2999-12-31 00:00:00' not null;

ALTER TABLE income ADD COLUMN date datetime ;
ALTER TABLE income ADD COLUMN descript varchar(255) ;
ALTER TABLE income ADD COLUMN memo varchar(255);
UPDATE income SET date= '2024-09-19 15:01:00';
####################################################################################################

CREATE DATABASE product;
use product;
CREATE TABLE stock_list
(
    `index`       INT AUTO_INCREMENT PRIMARY KEY, -- Auto-incrementing primary key
    standard_code VARCHAR(50),                    -- 표준코드 (standard code)
    short_code    VARCHAR(50),                    -- 단축코드 (short code)
    kr_stock_nm   VARCHAR(255),                   -- 한글 종목명 (Korean stock name)
    kr_stock_abbr VARCHAR(100),                   -- 한글 종목약명 (Korean stock abbreviation)
    market        varchar(100),
    price         INT

);
CREATE TABLE coin_list (
                             id INT AUTO_INCREMENT PRIMARY KEY,
                             coin_name VARCHAR(10) NOT NULL,
                             closing_price VARCHAR(50) NOT NULL,
                             updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE bond_list (
                           id BIGINT AUTO_INCREMENT PRIMARY KEY,
                           crno VARCHAR(255),
                           scrsItmsKcd VARCHAR(255),
                           isinCd VARCHAR(255),
                           scrsItmsKcdNm VARCHAR(255),
                           bondIsurNm VARCHAR(255),
                           isinCdNm VARCHAR(255)
);
CREATE TABLE deposite_list (
                                  ino BIGINT AUTO_INCREMENT PRIMARY KEY,
                                  fin_co_no BIGINT,
                                  kor_co_nm  varchar(1000),
                                  fin_prdt_cd varchar(1000),
                                  fin_prdt_nm varchar(1000),
                                  rsrv_type_nm varchar(1000),
                                  save_trm int,
                                  intr_rate double,
                                  intr_rate2 double
);
CREATE TABLE saving_list (
    fin_co_no VARCHAR(50) NOT NULL,         -- 금융회사 번호
    kor_co_nm VARCHAR(100),                 -- 금융회사 이름
    fin_prdt_cd VARCHAR(50),                -- 금융상품 코드
    fin_prdt_nm VARCHAR(100),               -- 금융상품 이름

    rsrv_type_nm VARCHAR(50),               -- 이율 종류 명칭 (단리, 복리 등)
    save_trm BIGINT,                        -- 가입 기간 (단위: 개월)
    intr_rate DOUBLE,                       -- 기본 이율
    intr_rate2 DOUBLE,                      -- 최고 우대 이율

    PRIMARY KEY (fin_co_no, fin_prdt_cd)    -- 금융회사 번호와 금융상품 코드로 복합 키 설정
);
drop table bond_list_price;
drop table coin_list_price;
drop table stock_list_price;
CREATE TABLE bond_list_price (
    `index` INT NOT NULL auto_increment,
    isinCd VARCHAR(255),
    isinCdNm VARCHAR(255),
    `date` datetime,
    1m_b_price int,
    2m_b_price int,
    3m_b_price int,
    4m_b_price int,
    5m_b_price int,
    6m_b_price int,
    primary key (`index`)
);

ALTER TABLE coin_list MODIFY COLUMN  updated_at datetime;
-- 1. 테이블을 기존 테이블에서 복사
CREATE TABLE coin_list_price AS SELECT * FROM coin_list;
-- 2. 인덱스 및 기본 키 추가
ALTER TABLE coin_list_price RENAME COLUMN id TO `index`;
ALTER TABLE coin_list_price ADD PRIMARY KEY (`index`);
ALTER TABLE coin_list_price RENAME COLUMN updated_at TO `date`;
-- 3. 각 컬럼의 타입 및 이름 변경
ALTER TABLE coin_list_price drop column closing_price;
ALTER TABLE coin_list_price ADD column m1_b_price INT;
ALTER TABLE coin_list_price ADD column m2_b_price INT;
ALTER TABLE coin_list_price ADD column m3_b_price INT;
ALTER TABLE coin_list_price ADD column m4_b_price INT;
ALTER TABLE coin_list_price ADD column m5_b_price INT;
ALTER TABLE coin_list_price ADD column m6_b_price INT;
UPDATE coin_list_price SET m1_b_price = closing_price * 0.9;
UPDATE coin_list_price SET m2_b_price = m1_b_price * 0.9;
UPDATE coin_list_price SET m3_b_price = m1_b_price * 0.9;
UPDATE coin_list_price SET m2_b_price = m1_b_price * 0.9;
UPDATE coin_list_price SET m2_b_price = m1_b_price * 0.9;
UPDATE coin_list_price SET m2_b_price = m1_b_price * 0.9;
CREATE TABLE stock_list_price (
    `index` INT NOT NULL auto_increment,                            -- 유저 관리번호
    short_code VARCHAR(50),
    `date` datetime,
    1m_b_price int,
    2m_b_price int,
    3m_b_price int,
    4m_b_price int,
    5m_b_price int,
    6m_b_price int,
    PRIMARY KEY (`index`)
);
ALTER TABLE stock_list_price RENAME COLUMN short_code TO standardCode;
UPDATE stock_list_price SET date = '2024-09-01 13:03:39';

####################################################################################
CREATE DATABASE outcome;
use outcome;
-- drop table outcome_averge;
CREATE TABLE outcome_average (
    `index` INT AUTO_INCREMENT PRIMARY KEY,
    household_head_age_group VARCHAR(50),
    income_expenditure_category VARCHAR(100),
    outcome INT,
    household_size DECIMAL(3, 2)
);
ALTER TABLE outcome_average RENAME COLUMN id TO `index`;
ALTER TABLE outcome_average MODIFY COLUMN  household_head_age_group VARCHAR(50) NOT NULL;
ALTER TABLE outcome_average MODIFY COLUMN  income_expenditure_category VARCHAR(100) NOT NULL;
ALTER TABLE outcome_average MODIFY COLUMN  outcome INT NOT NULL;
ALTER TABLE outcome_average MODIFY COLUMN  household_size DECIMAL(3, 2) NOT NULL;
ALTER TABLE outcome_average add COLUMN  quater varchar(10);
update outcome_average set quater="2024년 2분기";

CREATE TABLE outcome_user (
    `index` INT NOT NULL PRIMARY KEY,                                -- 색인 (Primary Key)
    uid INT NOT NULL,                                              -- 유저 관리번호
    income_expenditure_categoty VARCHAR(100) NOT NULL,             -- 카테고리
    date DATETIME NOT NULL,                                        -- 날짜
    amount BIGINT NOT NULL,                                        -- 금액
    descript VARCHAR(255),                                         -- 설명
    memo VARCHAR(255)                                              -- 메모
);
ALTER TABLE outcome_average RENAME COLUMN income_expenditure_category TO outcome_expenditure_category;
ALTER TABLE outcome_user RENAME COLUMN income_expenditure_categoty TO outcome_expenditure_category;
####################################################################################################

CREATE DATABASE board;
use board;
CREATE TABLE board_gallery (
    `index` INT NOT NULL PRIMARY KEY,              -- 게시글 관리 번호 (Primary Key)
    uid DOUBLE NOT NULL,                         -- 유저 관리번호
    title VARCHAR(50) NOT NULL,                  -- 제목 (갤러리 이름)
    img LONGBLOB,                                -- 갤러리 이미지 (이미지)
    b_content VARCHAR(255) NOT NULL,             -- 게시글 내용
    category VARCHAR(20) NOT NULL                -- 카테고리 (주식, 꿀팁 등)
);
ALTER TABLE board_gallery MODIFY COLUMN uid INT;
alter table board_gallery MODIFY COLUMN b_content text;
ALTER TABLE board_gallery ADD COLUMN time timestamp not null;
UPDATE board_gallery SET time = '2024-09-19 13:03:39';
