--
-- PostgreSQL database dump
--

\restrict OhMSjcfoYeQlEOe1Q3NAiFRzGhz5OzJ447NmhYoA0kOpw19TbtoyhHgoq2cc0pX

-- Dumped from database version 16.10
-- Dumped by pg_dump version 16.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance (
    id integer NOT NULL,
    schedule_id integer NOT NULL,
    class_name text NOT NULL,
    date date NOT NULL,
    roll_no text NOT NULL,
    status text NOT NULL,
    marked_at timestamp without time zone DEFAULT now() NOT NULL,
    session_time text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.attendance OWNER TO postgres;

--
-- Name: attendance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attendance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.attendance_id_seq OWNER TO postgres;

--
-- Name: attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attendance_id_seq OWNED BY public.attendance.id;


--
-- Name: exam_marks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exam_marks (
    id integer NOT NULL,
    schedule_id integer NOT NULL,
    class_name text NOT NULL,
    roll_no text NOT NULL,
    quiz numeric(5,2),
    assignment numeric(5,2),
    mid numeric(5,2),
    final numeric(5,2)
);


ALTER TABLE public.exam_marks OWNER TO postgres;

--
-- Name: exam_marks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.exam_marks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exam_marks_id_seq OWNER TO postgres;

--
-- Name: exam_marks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.exam_marks_id_seq OWNED BY public.exam_marks.id;


--
-- Name: exam_weights; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exam_weights (
    id integer NOT NULL,
    schedule_id integer NOT NULL,
    quiz integer DEFAULT 10 NOT NULL,
    assignment integer DEFAULT 10 NOT NULL,
    mid integer DEFAULT 20 NOT NULL,
    final integer DEFAULT 60 NOT NULL
);


ALTER TABLE public.exam_weights OWNER TO postgres;

--
-- Name: exam_weights_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.exam_weights_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exam_weights_id_seq OWNER TO postgres;

--
-- Name: exam_weights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.exam_weights_id_seq OWNED BY public.exam_weights.id;


--
-- Name: faculty_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.faculty_accounts (
    id integer NOT NULL,
    schedule_id integer NOT NULL,
    faculty_name text NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    email text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.faculty_accounts OWNER TO postgres;

--
-- Name: faculty_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.faculty_accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.faculty_accounts_id_seq OWNER TO postgres;

--
-- Name: faculty_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.faculty_accounts_id_seq OWNED BY public.faculty_accounts.id;


--
-- Name: finance_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.finance_accounts (
    id integer NOT NULL,
    username text NOT NULL,
    password text NOT NULL
);


ALTER TABLE public.finance_accounts OWNER TO postgres;

--
-- Name: finance_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.finance_accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.finance_accounts_id_seq OWNER TO postgres;

--
-- Name: finance_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.finance_accounts_id_seq OWNED BY public.finance_accounts.id;


--
-- Name: finance_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.finance_payments (
    id integer NOT NULL,
    person_type text NOT NULL,
    person_id text NOT NULL,
    person_name text NOT NULL,
    schedule_id integer,
    period text NOT NULL,
    amount numeric(10,2) DEFAULT 0 NOT NULL,
    paid_amount numeric(10,2) DEFAULT 0 NOT NULL,
    paid_date date,
    notes text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.finance_payments OWNER TO postgres;

--
-- Name: finance_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.finance_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.finance_payments_id_seq OWNER TO postgres;

--
-- Name: finance_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.finance_payments_id_seq OWNED BY public.finance_payments.id;


--
-- Name: finance_rates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.finance_rates (
    id integer NOT NULL,
    person_type text NOT NULL,
    person_id text NOT NULL,
    schedule_id integer,
    rate numeric(12,2) DEFAULT 0 NOT NULL
);


ALTER TABLE public.finance_rates OWNER TO postgres;

--
-- Name: finance_rates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.finance_rates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.finance_rates_id_seq OWNER TO postgres;

--
-- Name: finance_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.finance_rates_id_seq OWNED BY public.finance_rates.id;


--
-- Name: holidays; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.holidays (
    id integer NOT NULL,
    date date NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.holidays OWNER TO postgres;

--
-- Name: holidays_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.holidays_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.holidays_id_seq OWNER TO postgres;

--
-- Name: holidays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.holidays_id_seq OWNED BY public.holidays.id;


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schedules (
    id integer NOT NULL,
    user_id text NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    start_date date,
    end_date date,
    is_public boolean DEFAULT false NOT NULL
);


ALTER TABLE public.schedules OWNER TO postgres;

--
-- Name: schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.schedules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.schedules_id_seq OWNER TO postgres;

--
-- Name: schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schedules_id_seq OWNED BY public.schedules.id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    id integer NOT NULL,
    schedule_id integer NOT NULL,
    class_name text NOT NULL,
    roll_no text NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    email text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.students OWNER TO postgres;

--
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.students_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.students_id_seq OWNER TO postgres;

--
-- Name: students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.students_id_seq OWNED BY public.students.id;


--
-- Name: support_staff; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.support_staff (
    id integer NOT NULL,
    employee_id text NOT NULL,
    name text NOT NULL,
    designation text DEFAULT ''::text NOT NULL,
    department text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.support_staff OWNER TO postgres;

--
-- Name: support_staff_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.support_staff_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.support_staff_id_seq OWNER TO postgres;

--
-- Name: support_staff_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.support_staff_id_seq OWNED BY public.support_staff.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    pin text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: weekly_schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weekly_schedule (
    id integer NOT NULL,
    faculty text NOT NULL,
    subject text NOT NULL,
    class_name text NOT NULL,
    dept text NOT NULL,
    day text,
    location text,
    time_start text,
    time_end text,
    lec_lab text,
    type text,
    entry_date date,
    elective text,
    user_email text,
    sort_key integer,
    schedule_id integer
);


ALTER TABLE public.weekly_schedule OWNER TO postgres;

--
-- Name: weekly_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.weekly_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.weekly_schedule_id_seq OWNER TO postgres;

--
-- Name: weekly_schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.weekly_schedule_id_seq OWNED BY public.weekly_schedule.id;


--
-- Name: attendance id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance ALTER COLUMN id SET DEFAULT nextval('public.attendance_id_seq'::regclass);


--
-- Name: exam_marks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam_marks ALTER COLUMN id SET DEFAULT nextval('public.exam_marks_id_seq'::regclass);


--
-- Name: exam_weights id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam_weights ALTER COLUMN id SET DEFAULT nextval('public.exam_weights_id_seq'::regclass);


--
-- Name: faculty_accounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faculty_accounts ALTER COLUMN id SET DEFAULT nextval('public.faculty_accounts_id_seq'::regclass);


--
-- Name: finance_accounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finance_accounts ALTER COLUMN id SET DEFAULT nextval('public.finance_accounts_id_seq'::regclass);


--
-- Name: finance_payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finance_payments ALTER COLUMN id SET DEFAULT nextval('public.finance_payments_id_seq'::regclass);


--
-- Name: finance_rates id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finance_rates ALTER COLUMN id SET DEFAULT nextval('public.finance_rates_id_seq'::regclass);


--
-- Name: holidays id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.holidays ALTER COLUMN id SET DEFAULT nextval('public.holidays_id_seq'::regclass);


--
-- Name: schedules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedules ALTER COLUMN id SET DEFAULT nextval('public.schedules_id_seq'::regclass);


--
-- Name: students id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public.students_id_seq'::regclass);


--
-- Name: support_staff id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_staff ALTER COLUMN id SET DEFAULT nextval('public.support_staff_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: weekly_schedule id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_schedule ALTER COLUMN id SET DEFAULT nextval('public.weekly_schedule_id_seq'::regclass);


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance (id, schedule_id, class_name, date, roll_no, status, marked_at, session_time) FROM stdin;
1	1	2K22-BEE-14A	2026-06-22	001	P	2026-05-06 17:22:45.096076	12:00 PM
\.


--
-- Data for Name: exam_marks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.exam_marks (id, schedule_id, class_name, roll_no, quiz, assignment, mid, final) FROM stdin;
\.


--
-- Data for Name: exam_weights; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.exam_weights (id, schedule_id, quiz, assignment, mid, final) FROM stdin;
\.


--
-- Data for Name: faculty_accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.faculty_accounts (id, schedule_id, faculty_name, username, password, email, created_at) FROM stdin;
1	4	Dr. Ehsan ul Hassan	ehsan.hassan	bxsgytus		2026-05-07 06:55:18.839647
2	4	Ms. Asra Abid	asra.abid	auv64e9p		2026-05-07 06:55:18.839647
3	4	Mr. Munadi Ahmad Sial	munadi.sial	yxdwxu6m		2026-05-07 06:55:18.839647
4	4	Dr. Sajjad Hussain	sajjad.hussain	kapvqc29		2026-05-07 06:55:18.839647
5	4	Dr. Syed Taha Ali	syed.ali	wf9mgu8u		2026-05-07 06:55:18.839647
6	4	Dr. Attique Dawood	attique.dawood	tz23c6zq		2026-05-07 06:55:18.839647
7	4	Syed Jawad Hussain Shah	syed.shah	76zam7hv		2026-05-07 06:55:18.839647
8	4	Mr. Waseem Ahmed	waseem.ahmed	cgdv3ngw		2026-05-07 06:55:18.839647
9	4	Dr. Wasif Tanveer	wasif.tanveer	7ab95wv2		2026-05-07 06:55:18.839647
10	4	Mr. Yaruq Nadeem	yaruq.nadeem	cjsfrnf9		2026-05-07 06:55:18.839647
11	4	Dr. Tassawar Kazmi	tassawar.kazmi	u2tgm2qk		2026-05-07 06:55:18.839647
12	4	Mr. Maajid Maqbool	maajid.maqbool	tqkscgev		2026-05-07 06:55:18.839647
13	4	Dr. Neelma Naz	neelma.naz	bz7uxefd		2026-05-07 06:55:18.839647
14	4	Mr. Tariq Mansoor	tariq.mansoor	tqbnt2xn		2026-05-07 06:55:18.839647
15	4	Dr. Arbab Latif	arbab.latif	mnfag283		2026-05-07 06:55:18.839647
16	4	Dr. Javeria Ahmed	javeria.ahmed	z34438m8		2026-05-07 06:55:18.839647
17	4	Ms. Naema Asif	naema.asif	zbrs73tu		2026-05-07 06:55:18.839647
18	4	Dr. Sana Qadir	sana.qadir	s6hd276f		2026-05-07 06:55:18.839647
19	4	Dr. Faisal Shafait	faisal.shafait	xx2tx56g		2026-05-07 06:55:18.839647
20	4	Dr. Momina Moetesum	momina.moetesum	3vf8cpkg		2026-05-07 06:55:18.839647
21	4	Dr. Muhammad Bilal Ali	muhammad.ali	6kzxs4nj		2026-05-07 06:55:18.839647
22	4	Dr. Muhammad Ashraf	muhammad.ashraf	34fs6zag		2026-05-07 06:55:18.839647
23	4	Dr. Adnan Rashid	adnan.rashid	sarcs3sj		2026-05-07 06:55:18.839647
24	4	Dr. Muhammad Yousaf	muhammad.yousaf	vm25pqnp		2026-05-07 06:55:18.839647
25	4	Syeda Rabia Shaheen	syeda.shaheen	g39b6a9w		2026-05-07 06:55:18.839647
26	4	Mr. Taufiq ur Rehman	taufiq.rehman	asb7apsy		2026-05-07 06:55:18.839647
27	4	Dr. Tahira Anwar Lashari	tahira.lashari	2s5u5ch6		2026-05-07 06:55:18.839647
28	4	Dr. Farid Gul	farid.gul	wmqyefde		2026-05-07 06:55:18.839647
29	4	Dr. Huma Ghafoor	huma.ghafoor	x4cf6dav		2026-05-07 06:55:18.839647
30	4	Dr. Tauseef ur Rehman	tauseef.rehman	f7qfg6rv		2026-05-07 06:55:18.839647
31	4	Mr. Saeed Afzal	saeed.afzal	5yxuerwh		2026-05-07 06:55:18.839647
32	4	Dr. Hassaan Khaliq	hassaan.khaliq	uca4cbap		2026-05-07 06:55:18.839647
33	4	Dr. Wajid Mumtaz	wajid.mumtaz	fhbnyufw		2026-05-07 06:55:18.839647
34	4	Dr. Muhammad Imran	muhammad.imran	5avj68bd		2026-05-07 06:55:18.839647
35	4	Dr. Ibrar Hussain	ibrar.hussain	4yvhzgkw		2026-05-07 06:55:18.839647
36	4	Dr. Nauman Anwar Baig	nauman.baig	b8fqwvba		2026-05-07 06:55:18.839647
37	4	Dr. Azad Akhtar Siddiqui	azad.siddiqui	3p6482z7		2026-05-07 06:55:18.839647
38	4	Dr. Rizwan Ahmad	rizwan.ahmad	85ettsvx		2026-05-07 06:55:18.839647
39	4	Dr. Ahmed Naeem	ahmed.naeem	nbskatc5		2026-05-07 06:55:18.839647
40	4	Dr. Hasan Tahir Butt	hasan.butt	thmy4dc5		2026-05-07 06:55:18.839647
41	4	Ms. Ayesha Kanwal	ayesha.kanwal	ar8em7ve		2026-05-07 06:55:18.839647
42	4	Dr. Hashir Moheed Kiyani	hashir.kiyani	b964vgbc		2026-05-07 06:55:18.839647
43	4	Ms. Sobia Ashraf	sobia.ashraf	zn4f4vxq		2026-05-07 06:55:18.839647
44	4	Ms. Hareem Ashraf	hareem.ashraf	bnyzbevs		2026-05-07 06:55:18.839647
45	4	Mr. Hamza Saleem	hamza.saleem	d7vc8r5k		2026-05-07 06:55:18.839647
46	4	Dr. Muhammad Daud Abdullah Asif	muhammad.asif	f3nj3vhx		2026-05-07 06:55:18.839647
47	4	Dr. Muhammad Ahmad Rathore	muhammad.rathore	5ctxberb		2026-05-07 06:55:18.839647
48	4	Dr. Gibrail Islam	gibrail.islam	rjat9mbs		2026-05-07 06:55:18.839647
49	4	Dr. Muhammad Khuram Shahzad	muhammad.shahzad	tytk4hey		2026-05-07 06:55:18.839647
50	4	Dr. Junaid Younas	junaid.younas	5hagytue		2026-05-07 06:55:18.839647
51	4	Dr. Syed Imran Ali	syed.ali2	r9r45reh		2026-05-07 06:55:18.839647
52	4	Ms. Zahida Kausar	zahida.kausar	s4mjzu5n		2026-05-07 06:55:18.839647
53	4	Dr. Madiha Khalid	madiha.khalid	2f9fcy3d		2026-05-07 06:55:18.839647
54	4	Dr. Muhammad Imran Malik	muhammad.malik	4atqsqwe		2026-05-07 06:55:18.839647
55	4	Dr. Shah Khalid	shah.khalid	ss2mxrfv		2026-05-07 06:55:18.839647
56	4	Dr. Hirra Anwar	hirra.anwar	zgvknaw2		2026-05-07 06:55:18.839647
57	4	Dr. Mehwish Awan	mehwish.awan	rffckx56		2026-05-07 06:55:18.839647
58	4	Ms. Yusra Arshad	yusra.arshad	bwxg5dh7		2026-05-07 06:55:18.839647
59	4	Ms. Nikhar Azhar	nikhar.azhar	rjj2cdxr		2026-05-07 06:55:18.839647
60	4	Dr. Ayesha Maqbool	ayesha.maqbool	rqsgf4ya		2026-05-07 06:55:18.839647
61	4	Dr. Sarosh Tahir	sarosh.tahir	aaz7q94z		2026-05-07 06:55:18.839647
62	4	Dr. Nazia Pervaiz	nazia.pervaiz	nwnpn8vu		2026-05-07 06:55:18.839647
63	4	Ms. Sahar Arshad	sahar.arshad	che74p54		2026-05-07 06:55:18.839647
64	4	Dr. Muhammad Moazam Fraz	muhammad.fraz	uhwn4p4j		2026-05-07 06:55:18.839647
65	4	Dr. Fahad Ahmed Satti	fahad.satti	erutt2a4		2026-05-07 06:55:18.839647
66	4	Dr. Rabia Irfan	rabia.irfan	tdrdhn72		2026-05-07 06:55:18.839647
67	4	Ms. Maria Jamshaid	maria.jamshaid	cfqpb57b		2026-05-07 06:55:18.839647
68	4	Dr. Usman Khan	usman.khan	m64r2kh2		2026-05-07 06:55:18.839647
69	4	Ms. Ayesha Habib	ayesha.habib	ah9vm4pm		2026-05-07 06:55:18.839647
70	4	Dr. Imran Shahzad	imran.shahzad	e7x54fbe		2026-05-07 06:55:18.839647
71	4	Dr. Muhammad Moazzam Ali	muhammad.ali2	ty2kc7hm		2026-05-07 06:55:18.839647
72	4	Dr. Salman Abdul Ghafoor	salman.ghafoor	3pbz9mrq		2026-05-07 06:55:18.839647
73	4	Mr. Abdul Mateen	abdul.mateen	verr3rwp		2026-05-07 06:55:18.839647
74	4	Dr. Muhammad Mustafa Tahseen	muhammad.tahseen	errurkjk		2026-05-07 06:55:18.839647
75	4	Dr. Arshad Siddiqui	arshad.siddiqui	g8ffh4q8		2026-05-07 06:55:18.839647
76	4	Dr. Muhammad Saad Zia	muhammad.zia	p7zhrwnw		2026-05-07 06:55:18.839647
77	4	Dr. Muhammad Jameel Nawaz	muhammad.nawaz	8qwyx4bn		2026-05-07 06:55:18.839647
78	4	Dr. Neelma Riaz	neelma.riaz	4f66eaf2		2026-05-07 06:55:18.839647
79	4	Dr. Hina Munir Dutt	hina.dutt	mf3wm2jj		2026-05-07 06:55:18.839647
80	4	Ms. Ansar Shahzadi	ansar.shahzadi	qjruqhu2		2026-05-07 06:55:18.839647
81	4	Dr. Mehvish Rashid	mehvish.rashid	82eph35q		2026-05-07 06:55:18.839647
82	4	Dr. Zuhair Zafar	zuhair.zafar	fdvyjhg3		2026-05-07 06:55:18.839647
83	4	Dr. Oumar Saleem	oumar.saleem	7ubra77j		2026-05-07 06:55:18.839647
84	4	Dr. Aimal Tariq Rextin	aimal.rextin	n84ghgtu		2026-05-07 06:55:18.839647
85	4	Dr. Naima Iltaaf	naima.iltaaf	ss6amp7u		2026-05-07 06:55:18.839647
86	4	Dr. Samia Tahir	samia.tahir	qdxky2n2		2026-05-07 06:55:18.839647
87	4	Ms. Tabassam Gul	tabassam.gul	z2z7ur7t		2026-05-07 06:55:18.839647
88	4	Dr. Mehwish Fatima	mehwish.fatima	n84mxjct		2026-05-07 06:55:18.839647
89	4	Dr. Sidra Shafiq	sidra.shafiq	cd8tscku		2026-05-07 06:55:18.839647
90	4	Dr. Seemab Latif	seemab.latif	jqqnhxnn		2026-05-07 06:55:18.839647
91	4	Ms. Hina Yousaf	hina.yousaf	ah5gbc2v		2026-05-07 06:55:18.839647
92	4	Dr. Fatima Abdullah	fatima.abdullah	t9mhpe2m		2026-05-07 06:55:18.839647
93	4	Dr. Qaiser Riaz	qaiser.riaz	zk4gng8n		2026-05-07 06:55:18.839647
94	4	Dr. Imran Malik	imran.malik	3kfpeq3t		2026-05-07 06:55:18.839647
95	4	Mr. Omar Zeb	omar.zeb	52drr85e		2026-05-07 06:55:18.839647
96	4	Dr. Ayesha Hakim	ayesha.hakim	x4kenc3d		2026-05-07 06:55:18.839647
97	4	Dr. Farzana Jabeen	farzana.jabeen	5nmqmbsj		2026-05-07 06:55:18.839647
98	4	Dr. Sara Shakil	sara.shakil	xun4vanc		2026-05-07 06:55:18.839647
99	4	Dr. Sohail Iqbal	sohail.iqbal	yxhfy6g2		2026-05-07 06:55:18.839647
100	4	Dr. Sadiq Amin	sadiq.amin	57x4sazj		2026-05-07 06:55:18.839647
101	4	Dr. Saira Zainab	saira.zainab	vg68qm4v		2026-05-07 06:55:18.839647
102	4	Dr. Fahd Sikandar Khan	fahd.khan	pj7xbyjc		2026-05-07 06:55:18.839647
103	4	Mr. Muhammad Usman Ghani	muhammad.ghani	d3xzvpjp		2026-05-07 06:55:18.839647
104	4	Mr. Jamil Ahmad	jamil.ahmad	8kgzj7ur		2026-05-07 06:55:18.839647
105	4	Mr. Saif Ullah	saif.ullah	qmu4e9sp		2026-05-07 06:55:18.839647
106	4	Mr. Ahsan Azhar	ahsan.azhar	jd92ekht		2026-05-07 06:55:18.839647
107	4	Mr. Ammar Ahmed	ammar.ahmed	5saece7b		2026-05-07 06:55:18.839647
108	4	Dr. Sobia Jamil	sobia.jamil	89pkhzjk		2026-05-07 06:55:18.839647
109	4	Mr. Salman Mushtaq	salman.mushtaq	t5kj7h9z		2026-05-07 06:55:18.839647
110	4	Mr. Hassan Jamil	hassan.jamil	n268bdjx		2026-05-07 06:55:18.839647
111	4	Mr. Huzaifa Abbas	huzaifa.abbas	gk4eej4k		2026-05-07 06:55:18.839647
112	4	Dr. Nosherwan Shoaib	nosherwan.shoaib	ucv8gg3b		2026-05-07 06:55:18.839647
113	4	Mr. Habeel Ahmed	habeel.ahmed	y48w4rhq		2026-05-07 06:55:18.839647
114	4	Mr. Habeel Ahmad	habeel.ahmad	2hcuquj3		2026-05-07 06:55:18.839647
115	4	Dr. Quanita Kiran	quanita.kiran	cqubgehc		2026-05-07 06:55:18.839647
116	4	Mr. Muhammad Nashit Shah	muhammad.shah	e6xm8dgv		2026-05-07 06:55:18.839647
117	4	Ms. Sadia Arshad	sadia.arshad	j7ch8cqc		2026-05-07 06:55:18.839647
118	4	Mr. Muhammad Abdullah	muhammad.abdullah	nbkdb8yg		2026-05-07 06:55:18.839647
119	4	Hafiz Muhammad Siddique	hafiz.siddique	g8vfw647		2026-05-07 06:55:18.839647
120	4	Dr. Atifa Kanwal	atifa.kanwal	pujbu28u		2026-05-07 06:55:18.839647
121	4	Ms. Sara Tariq Sheikh	sara.sheikh	nw2gf7un		2026-05-07 06:55:18.839647
122	4	Ms. Maryam Sajjad	maryam.sajjad	3jswa6z2		2026-05-07 06:55:18.839647
123	4	Mr. Arshad Nazir	arshad.nazir	dxsbh42f		2026-05-07 06:55:18.839647
124	4	Mr. Jaudat Mamoon	jaudat.mamoon	mrg7xt2b		2026-05-07 06:55:18.839647
125	4	Dr. Khursheed Muhammad	khursheed.muhammad	45n989zq		2026-05-07 06:55:18.839647
126	4	Dr. Abdul Haleem Hamid	abdul.hamid	uyrjvbrv		2026-05-07 06:55:18.839647
127	4	Dr. Zafar Ali	zafar.ali	cy26fgpj		2026-05-07 06:55:18.839647
128	4	Dr. Farkhanda Afzal	farkhanda.afzal	7bfrsnc2		2026-05-07 06:55:18.839647
129	4	Dr. Adnan Aslam	adnan.aslam	mb6nxgd2		2026-05-07 06:55:18.839647
130	4	Dr. Rai Sajjad Saif	rai.saif	345w2kmg		2026-05-07 06:55:18.839647
131	4	Dr. Bilal Ahmed	bilal.ahmed	u4h9gacs		2026-05-07 06:55:18.839647
\.


--
-- Data for Name: finance_accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.finance_accounts (id, username, password) FROM stdin;
1	admin	finance123
2	Seerat Fatima	Fatima@123
\.


--
-- Data for Name: finance_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.finance_payments (id, person_type, person_id, person_name, schedule_id, period, amount, paid_amount, paid_date, notes) FROM stdin;
\.


--
-- Data for Name: finance_rates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.finance_rates (id, person_type, person_id, schedule_id, rate) FROM stdin;
1	staff	SS-001	\N	25000.00
\.


--
-- Data for Name: holidays; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.holidays (id, date, name) FROM stdin;
2	2026-05-01	Labour Day
\.


--
-- Data for Name: schedules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schedules (id, user_id, name, created_at, start_date, end_date, is_public) FROM stdin;
4	Alamdar Hussain	Summer 2026	2026-05-06 12:09:14.208927	2026-06-22	2026-08-23	t
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, schedule_id, class_name, roll_no, name, created_at, email) FROM stdin;
1	4	2K22-BEE-14C	2K22-BEE-01	Ahmed Ali	2026-05-06 16:31:57.75605	
2	4	2K22-BEE-14C	2K22-BEE-02	Sara Khan	2026-05-06 16:31:58.025677	
3	4	2K22-BEE-14C	2K22-BEE-03	Usman Tariq	2026-05-06 16:31:58.030616	
\.


--
-- Data for Name: support_staff; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.support_staff (id, employee_id, name, designation, department) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password, pin) FROM stdin;
1	admin	admin123	
2	Alamdar Hussaiin	Hussain@123	
3	Alamdar Hussain	Hussain@123	
4	Seerat Fatima	Fatima@123	4880
5	Bashir Ahmad	Ahmad@123	4880
\.


--
-- Data for Name: weekly_schedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.weekly_schedule (id, faculty, subject, class_name, dept, day, location, time_start, time_end, lec_lab, type, entry_date, elective, user_email, sort_key, schedule_id) FROM stdin;
2454	Dr. Bilal Ahmed	Linear Algebra	2K25-BSDS-3A	H&S	Thu	CR-01-UG Block	04:00 PM	05:00 PM	Lec	Missed	2026-05-07		admin	960	\N
2483	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Tue	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2484	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14A	ECE	Tue	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
4	Dr. Arbab Latif	Community Service Learning	2K22-BEE-14C	ECE	Tue	CR-01-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-05-05		admin	660	\N
5	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14A	ECE	Mon	Computing Lab-07	09:00 AM	10:00 AM	Lab	\N	\N	Elective		540	\N
6	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Mon	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	\N
7	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14A	ECE	Mon	Computing Lab-07	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
8	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Mon	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	\N
9	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14A	ECE	Mon	Computing Lab-07	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
10	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14A	ECE	Mon	CR-10-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
11	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Mon	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
12	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14A	ECE	Mon	CR-17-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
13	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14A	ECE	Mon	CR-18-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
14	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14A	ECE	Mon	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
15	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14A	ECE	Mon	Computing Lab-07	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
16	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14A	ECE	Mon	Computing Lab-09	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
17	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Mon	Embedded Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
18	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14A	ECE	Mon	Computing Lab-07	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
19	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14A	ECE	Mon	Computing Lab-09	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
20	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Mon	Embedded Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
21	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14A	ECE	Mon	Computing Lab-07	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
22	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14A	ECE	Mon	Computing Lab-09	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
23	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Mon	Embedded Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
24	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14A	H&S	Thu	CR-13-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
25	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14A	H&S	Thu	CR-13-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
26	Dr. Wasif Tanveer	Community Service Learning	2K22-BEE-14A	ECE	Thu	SMRIMMS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
27	Dr. Wasif Tanveer	Community Service Learning	2K22-BEE-14A	ECE	Thu	SMRIMMS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
28	Dr. Wasif Tanveer	Community Service Learning	2K22-BEE-14A	ECE	Thu	SMRIMMS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
29	Mr. Yaruq Nadeem	Entrepreneurship	2K22-BEE-14A	H&S	Tue	CR-11-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
30	Mr. Yaruq Nadeem	Entrepreneurship	2K22-BEE-14A	H&S	Tue	CR-11-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
31	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14A	ECE	Tue	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
32	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14A	ECE	Tue	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
33	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Tue	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
34	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14A	ECE	Tue	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
35	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14A	ECE	Tue	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
36	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14A	ECE	Tue	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
37	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14A	ECE	Tue	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
38	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Tue	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
39	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14A	ECE	Tue	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
40	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14A	ECE	Tue	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
41	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Tue	CR-09-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	\N
42	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14A	ECE	Tue	CR-12-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	\N
43	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Tue	CR-01-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
44	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14A	ECE	Tue	CR-09-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
45	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14A	ECE	Tue	CR-11-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
46	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14A	ECE	Tue	CR-12-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
47	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Tue	CR-01-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
48	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14A	ECE	Tue	CR-09-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
49	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14A	ECE	Tue	CR-11-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
50	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14A	ECE	Tue	CR-12-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
51	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14A	ECE	Wed	CR-13-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	\N
52	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14A	ECE	Wed	CR-13-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
53	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14A	ECE	Mon	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
54	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Wed	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
55	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14A	ECE	Wed	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
56	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14A	ECE	Wed	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
57	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14A	ECE	Wed	Computing Lab-03	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
58	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14A	ECE	Wed	Computing Lab-04	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
59	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14A	ECE	Wed	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
60	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14A	ECE	Wed	Computing Lab-03	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
61	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14A	ECE	Wed	Computing Lab-04	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
62	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14A	ECE	Wed	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
63	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14A	ECE	Wed	Computing Lab-03	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
64	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14A	ECE	Wed	Computing Lab-04	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
65	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14A	ECE	Wed	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
66	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14B	ECE	Mon	Computing Lab-07	09:00 AM	10:00 AM	Lab	\N	\N	Elective		540	\N
67	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Mon	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	\N
68	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14B	ECE	Mon	Computing Lab-07	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
69	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Mon	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	\N
70	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14B	ECE	Mon	Computing Lab-07	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
71	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14B	ECE	Mon	CR-10-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
72	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Mon	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
73	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14B	ECE	Mon	CR-17-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
74	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14B	ECE	Mon	CR-18-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
75	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14B	ECE	Mon	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
76	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14B	ECE	Mon	Computing Lab-07	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
77	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14B	ECE	Mon	Computing Lab-09	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
78	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Mon	Embedded Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
79	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14B	ECE	Mon	Computing Lab-07	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
80	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14B	ECE	Mon	Computing Lab-09	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
81	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Mon	Embedded Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
82	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14B	ECE	Mon	Computing Lab-07	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
83	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14B	ECE	Mon	Computing Lab-09	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
84	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Mon	Embedded Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
85	Mr. Maajid Maqbool	Entrepreneurship	2K22-BEE-14B	FoC	Thu	CR-13-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
86	Mr. Maajid Maqbool	Entrepreneurship	2K22-BEE-14B	FoC	Thu	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
87	Dr. Neelma Naz	Community Service Learning	2K22-BEE-14B	ECE	Thu	SMRIMMS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
88	Dr. Neelma Naz	Community Service Learning	2K22-BEE-14B	ECE	Thu	SMRIMMS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
89	Dr. Neelma Naz	Community Service Learning	2K22-BEE-14B	ECE	Thu	SMRIMMS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
90	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14B	H&S	Tue	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
91	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14B	H&S	Tue	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
92	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14B	ECE	Tue	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
93	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14B	ECE	Tue	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
94	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Tue	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
95	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14B	ECE	Tue	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
96	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14B	ECE	Tue	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
97	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14B	ECE	Tue	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
98	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14B	ECE	Tue	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
99	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Tue	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
100	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14B	ECE	Tue	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
101	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14B	ECE	Tue	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
102	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Tue	CR-09-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	\N
103	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14B	ECE	Tue	CR-12-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	\N
104	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Tue	CR-01-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
105	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14B	ECE	Tue	CR-09-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
106	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14B	ECE	Tue	CR-11-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
107	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14B	ECE	Tue	CR-12-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
108	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Tue	CR-01-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
109	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14B	ECE	Tue	CR-09-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
110	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14B	ECE	Tue	CR-11-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
111	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14B	ECE	Tue	CR-12-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
112	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14B	ECE	Wed	CR-13-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	\N
113	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14B	ECE	Wed	CR-13-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
114	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14B	ECE	Wed	CR-05-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
115	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Wed	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
116	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14B	ECE	Wed	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
117	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14B	ECE	Wed	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
118	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14B	ECE	Wed	Computing Lab-03	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
119	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14B	ECE	Wed	Computing Lab-04	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
120	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14B	ECE	Wed	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
121	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14B	ECE	Wed	Computing Lab-03	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
122	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14B	ECE	Wed	Computing Lab-04	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
123	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14B	ECE	Wed	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
124	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14B	ECE	Wed	Computing Lab-03	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
125	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14B	ECE	Wed	Computing Lab-04	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
126	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14B	ECE	Wed	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
127	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14C	ECE	Mon	Computing Lab-07	09:00 AM	10:00 AM	Lab	\N	\N	Elective		540	\N
128	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Mon	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	\N
129	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14C	ECE	Mon	Computing Lab-07	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
130	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Mon	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	\N
131	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14C	ECE	Mon	Computing Lab-07	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
132	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14C	ECE	Mon	CR-10-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
133	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Mon	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
134	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14C	ECE	Mon	CR-17-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
135	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14C	ECE	Mon	CR-18-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
136	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14C	ECE	Mon	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
137	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14C	ECE	Mon	Computing Lab-07	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
138	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14C	ECE	Mon	Computing Lab-09	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
139	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Mon	Embedded Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
140	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14C	ECE	Mon	Computing Lab-07	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
141	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14C	ECE	Mon	Computing Lab-09	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
142	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Mon	Embedded Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
143	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14C	ECE	Mon	Computing Lab-07	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
144	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14C	ECE	Mon	Computing Lab-09	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
145	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Mon	Embedded Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
146	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14C	H&S	Thu	CR-09-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
147	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14C	H&S	Thu	CR-09-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
148	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14C	H&S	Thu	CR-09-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
149	Dr. Arbab Latif	Community Service Learning	2K22-BEE-14C	ECE	Thu	SMRIMMS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
150	Dr. Arbab Latif	Community Service Learning	2K22-BEE-14C	ECE	Thu	SMRIMMS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
151	Dr. Arbab Latif	Community Service Learning	2K22-BEE-14C	ECE	Thu	SMRIMMS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
152	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14C	ECE	Tue	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
153	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14C	ECE	Tue	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
154	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Tue	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
155	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14C	ECE	Tue	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
156	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14C	ECE	Tue	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
157	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14C	ECE	Tue	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
158	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14C	ECE	Tue	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
159	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Tue	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
160	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14C	ECE	Tue	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
161	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14C	ECE	Tue	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
162	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Tue	CR-09-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	\N
163	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14C	ECE	Tue	CR-12-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	\N
164	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Tue	CR-01-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
165	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14C	ECE	Tue	CR-09-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
166	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14C	ECE	Tue	CR-11-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
167	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14C	ECE	Tue	CR-12-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
168	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Tue	CR-01-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
169	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14C	ECE	Tue	CR-09-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
170	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14C	ECE	Tue	CR-11-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
171	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14C	ECE	Tue	CR-12-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
172	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14C	H&S	Wed	CR-09-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
173	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14C	ECE	Wed	CR-13-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	\N
174	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14C	ECE	Wed	CR-13-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
175	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14C	ECE	Wed	CR-05-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
176	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Wed	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
177	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14C	ECE	Wed	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
178	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14C	ECE	Wed	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
179	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14C	ECE	Wed	Computing Lab-03	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
180	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14C	ECE	Wed	Computing Lab-04	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
181	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14C	ECE	Wed	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
182	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14C	ECE	Wed	Computing Lab-03	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
183	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14C	ECE	Wed	Computing Lab-04	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
184	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14C	ECE	Wed	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
185	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14C	ECE	Wed	Computing Lab-03	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
186	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14C	ECE	Wed	Computing Lab-04	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
187	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14C	ECE	Wed	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
188	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14D	ECE	Mon	Computing Lab-07	09:00 AM	10:00 AM	Lab	\N	\N	Elective		540	\N
189	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Mon	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	\N
190	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14D	ECE	Mon	Computing Lab-07	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
191	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Mon	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	\N
192	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14D	ECE	Mon	Computing Lab-07	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
193	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14D	ECE	Mon	CR-10-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
194	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Mon	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
195	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14D	ECE	Mon	CR-17-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
196	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14D	ECE	Mon	CR-18-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
197	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14D	ECE	Mon	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
198	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14D	ECE	Mon	Computing Lab-07	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
199	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14D	ECE	Mon	Computing Lab-09	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
200	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Mon	Embedded Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
201	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14D	ECE	Mon	Computing Lab-07	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
202	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14D	ECE	Mon	Computing Lab-09	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
203	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Mon	Embedded Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
204	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14D	ECE	Mon	Computing Lab-07	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
205	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14D	ECE	Mon	Computing Lab-09	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
206	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Mon	Embedded Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
207	Dr. Ehsan ul Hassan	Professional Ethics	2K22-BEE-14D	H&S	Thu	CR-05-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
208	Dr. Ehsan ul Hassan	Professional Ethics	2K22-BEE-14D	H&S	Thu	CR-05-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
209	Dr. Javeria Ahmed	Community Service Learning	2K22-BEE-14D	ECE	Thu	SMRIMMS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
210	Dr. Javeria Ahmed	Community Service Learning	2K22-BEE-14D	ECE	Thu	SMRIMMS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
211	Dr. Javeria Ahmed	Community Service Learning	2K22-BEE-14D	ECE	Thu	SMRIMMS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
212	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14D	H&S	Tue	CR-04-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
213	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14D	H&S	Tue	CR-04-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
214	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14D	ECE	Tue	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
215	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14D	ECE	Tue	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
216	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Tue	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
217	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14D	ECE	Tue	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
218	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14D	ECE	Tue	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
219	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14D	ECE	Tue	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
220	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14D	ECE	Tue	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
221	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Tue	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
222	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14D	ECE	Tue	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
223	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14D	ECE	Tue	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
224	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Tue	CR-09-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	\N
225	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14D	ECE	Tue	CR-12-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	\N
226	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Tue	CR-01-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
227	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14D	ECE	Tue	CR-09-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
228	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14D	ECE	Tue	CR-11-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
229	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14D	ECE	Tue	CR-12-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	\N
230	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Tue	CR-01-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
231	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14D	ECE	Tue	CR-09-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
232	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14D	ECE	Tue	CR-11-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
233	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14D	ECE	Tue	CR-12-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	\N
234	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14D	ECE	Wed	CR-13-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	\N
235	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14D	ECE	Wed	CR-13-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
236	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14D	ECE	Wed	CR-05-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
237	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Wed	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
238	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14D	ECE	Wed	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
239	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14D	ECE	Wed	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
240	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14D	ECE	Wed	Computing Lab-03	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
241	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14D	ECE	Wed	Computing Lab-04	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
242	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14D	ECE	Wed	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
243	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14D	ECE	Wed	Computing Lab-03	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
244	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14D	ECE	Wed	Computing Lab-04	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
245	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14D	ECE	Wed	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
246	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14D	ECE	Wed	Computing Lab-03	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
247	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14D	ECE	Wed	Computing Lab-04	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
248	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14D	ECE	Wed	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
249	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Mon	CR-15-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	\N
250	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Mon	CR-15-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	\N
251	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Mon	CR-15-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
252	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Mon	Computing Lab-01	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
253	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Mon	Computing Lab-01	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
254	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Mon	Computing Lab-01	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
255	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13A	FoC	Thu	CR-08-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	\N
256	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13A	FoC	Thu	CR-08-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	\N
257	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Thu	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
258	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Thu	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
259	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
260	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
261	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
262	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Tue	CR-05-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	\N
263	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13A	FoC	Tue	Computing Lab-02	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
264	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13A	FoC	Tue	Computing Lab-02	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
265	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13A	FoC	Tue	Computing Lab-02	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	\N
266	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13A	FoC	Tue	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
267	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13A	FoC	Tue	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
268	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13A	FoC	Tue	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
269	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13A	FoC	Wed	CR-04-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	\N
270	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13A	FoC	Wed	CR-04-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	\N
271	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13A	FoC	Wed	CR-04-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
272	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13A	FoC	Wed	CR-04-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
273	Dr. Muhammad Bilal Ali	Community Service Learning	2K22-BESE-13A	FoC	Wed	SEECS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
274	Dr. Muhammad Bilal Ali	Community Service Learning	2K22-BESE-13A	FoC	Wed	SEECS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
275	Dr. Muhammad Bilal Ali	Community Service Learning	2K22-BESE-13A	FoC	Wed	SEECS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
276	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Mon	CR-15-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	\N
277	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Mon	CR-15-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	\N
278	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Mon	CR-15-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
279	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Mon	Computing Lab-01	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
280	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Mon	Computing Lab-01	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
281	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Mon	Computing Lab-01	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
282	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13B	FoC	Thu	CR-08-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	\N
283	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13B	FoC	Thu	CR-08-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	\N
284	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Thu	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
285	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Thu	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
286	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
287	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
288	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
289	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Tue	CR-05-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	\N
290	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13B	FoC	Tue	Computing Lab-02	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
291	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13B	FoC	Tue	Computing Lab-02	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
292	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13B	FoC	Tue	Computing Lab-02	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	\N
293	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13B	FoC	Tue	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
294	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13B	FoC	Tue	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
295	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13B	FoC	Tue	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
296	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13B	FoC	Wed	CR-04-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	\N
297	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13B	FoC	Wed	CR-04-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	\N
298	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13B	FoC	Wed	CR-04-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
299	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13B	FoC	Wed	CR-04-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
300	Dr. Muhammad Ashraf	Community Service Learning	2K22-BESE-13B	FoC	Wed	SEECS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
301	Dr. Muhammad Ashraf	Community Service Learning	2K22-BESE-13B	FoC	Wed	SEECS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
302	Dr. Muhammad Ashraf	Community Service Learning	2K22-BESE-13B	FoC	Wed	SEECS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
303	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12A	FoC	Fri	CR-07-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
304	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12A	H&S	Fri	CR-07-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
305	Syeda Rabia Shaheen	Principles of Sociology	2K22-BSCS-12A	H&S	Fri	CR-07-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
306	Syeda Rabia Shaheen	Principles of Sociology	2K22-BSCS-12A	H&S	Thu	Lecture Hall-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
307	Syeda Rabia Shaheen	Principles of Sociology	2K22-BSCS-12A	H&S	Thu	Lecture Hall-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
308	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12A	H&S	Thu	Lecture Hall-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
309	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12A	FoC	Thu	CR-07-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
310	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12A	FoC	Wed	CR-07-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
311	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12A	H&S	Wed	CR-07-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
312	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12A	FoC	Wed	SEECS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
313	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12A	FoC	Wed	SEECS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
314	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12A	FoC	Wed	SEECS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
315	Syeda Rabia Shaheen	Principles of Sociology	2K22-BSCS-12B	H&S	Fri	Lecture Hall-PG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
316	Syeda Rabia Shaheen	Principles of Sociology	2K22-BSCS-12B	H&S	Fri	Lecture Hall-PG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
317	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12B	FoC	Fri	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
318	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12B	H&S	Fri	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
319	Syeda Rabia Shaheen	Principles of Sociology	2K22-BSCS-12B	H&S	Thu	CR-18-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
320	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12B	H&S	Thu	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
321	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12B	FoC	Thu	CR-07-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
322	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12B	FoC	Wed	CR-06-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
323	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12B	H&S	Wed	CR-06-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
324	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12B	FoC	Wed	SEECS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
325	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12B	FoC	Wed	SEECS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
326	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12B	FoC	Wed	SEECS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
327	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12C	H&S	Fri	CR-08-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
328	Dr. Tahira Anwar Lashari	Principles of Sociology	2K22-BSCS-12C	FoC	Fri	CR-08-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
329	Dr. Tahira Anwar Lashari	Principles of Sociology	2K22-BSCS-12C	FoC	Fri	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
330	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12C	FoC	Fri	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
331	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12C	H&S	Thu	CR-12-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
332	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12C	FoC	Thu	CR-12-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
333	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12C	H&S	Wed	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
334	Dr. Tahira Anwar Lashari	Principles of Sociology	2K22-BSCS-12C	FoC	Wed	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
335	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12C	FoC	Wed	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
336	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12C	FoC	Wed	SEECS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
337	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12C	FoC	Wed	SEECS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
338	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12C	FoC	Wed	SEECS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
339	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Fri	CR-19-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
340	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15A	ECE	Fri	DSP & Comm Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
341	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15A	ECE	Fri	DSP & Comm Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
342	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15A	ECE	Fri	DSP & Comm Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
343	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Mon	CR-19-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
344	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15A	H&S	Mon	CR-19-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
345	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15A	ECE	Mon	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
346	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15A	ECE	Mon	CR-20-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
347	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15A	ECE	Mon	Lecture Hall-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
348	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15A	ECE	Mon	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
349	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15A	ECE	Mon	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
350	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15A	ECE	Mon	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
351	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15A	ECE	Thu	CR-19-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
352	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15A	H&S	Thu	CR-19-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
353	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Thu	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
354	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Thu	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
355	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Thu	Control System Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
356	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Thu	Control System Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
357	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Thu	Control System Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
358	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15A	ECE	Tue	CR-19-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
359	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15A	ECE	Tue	CR-19-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
360	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Tue	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
361	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15A	ECE	Tue	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
362	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15A	ECE	Tue	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
363	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15A	ECE	Tue	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
364	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Tue	DSP & Comm Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
365	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Tue	DSP & Comm Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
366	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Tue	DSP & Comm Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
367	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Wed	CR-19-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
368	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15A	H&S	Wed	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
369	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15A	ECE	Wed	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
370	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15A	ECE	Wed	EMS Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
371	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15A	ECE	Wed	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
372	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15A	ECE	Wed	EMS Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
373	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15A	ECE	Wed	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
374	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15A	ECE	Wed	EMS Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
375	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Fri	CR-20-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
376	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15B	ECE	Fri	DSP & Comm Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
377	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15B	ECE	Fri	DSP & Comm Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
378	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15B	ECE	Fri	DSP & Comm Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
379	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15B	H&S	Mon	CR-20-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
380	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Mon	CR-20-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
381	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15B	ECE	Mon	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
382	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15B	ECE	Mon	CR-20-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
383	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15B	ECE	Mon	Lecture Hall-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
384	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15B	ECE	Mon	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
385	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15B	ECE	Mon	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
386	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15B	ECE	Mon	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
387	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Thu	Control System Lab	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
388	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Thu	Control System Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
389	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Thu	Control System Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
390	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15B	H&S	Thu	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
391	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15B	ECE	Thu	CR-20-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
392	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15B	ECE	Thu	CR-20-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
393	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Tue	DSP & Comm Lab	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
394	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Tue	DSP & Comm Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
395	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Tue	DSP & Comm Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
396	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15B	ECE	Tue	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
397	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15B	ECE	Tue	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
398	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15B	ECE	Tue	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
399	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Tue	CR-20-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
400	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15B	ECE	Tue	CR-20-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
401	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Wed	CR-20-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
402	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Wed	CR-20-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
403	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Wed	CR-20-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
404	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15B	H&S	Wed	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
405	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15B	ECE	Wed	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
406	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15B	ECE	Wed	EMS Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
460	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Mon	DSP & Comm Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
407	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15B	ECE	Wed	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
408	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15B	ECE	Wed	EMS Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
409	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15B	ECE	Wed	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
410	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15B	ECE	Wed	EMS Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
411	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Fri	CR-19-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
412	Dr. Ibrar Hussain	Numerical Methods	2K23-BEE-15C	H&S	Fri	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
413	Dr. Sajjad Hussain	Communication Systems	2K23-BEE-15C	ECE	Mon	CR-16-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
414	Dr. Sajjad Hussain	Communication Systems	2K23-BEE-15C	ECE	Mon	CR-16-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
415	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15C	ECE	Mon	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
416	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15C	ECE	Mon	CR-20-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
417	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15C	ECE	Mon	Lecture Hall-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
418	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15C	ECE	Mon	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
419	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15C	ECE	Mon	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
420	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15C	ECE	Mon	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
421	Dr. Nauman Anwar Baig	Digital Signal Processing	2K23-BEE-15C	ECE	Mon	CR-19-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
422	Dr. Nauman Anwar Baig	Digital Signal Processing	2K23-BEE-15C	ECE	Mon	CR-19-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
423	Dr. Nauman Anwar Baig	Digital Signal Processing	2K23-BEE-15C	ECE	Thu	CR-20-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
424	Dr. Ibrar Hussain	Numerical Methods	2K23-BEE-15C	H&S	Thu	CR-20-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
425	Dr. Ibrar Hussain	Numerical Methods	2K23-BEE-15C	H&S	Thu	CR-20-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
426	Dr. Sajjad Hussain	Communication Systems	2K23-BEE-15C	ECE	Thu	DSP & Comm Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
427	Dr. Sajjad Hussain	Communication Systems	2K23-BEE-15C	ECE	Thu	DSP & Comm Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
428	Dr. Sajjad Hussain	Communication Systems	2K23-BEE-15C	ECE	Thu	DSP & Comm Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
429	Dr. Sajjad Hussain	Communication Systems	2K23-BEE-15C	ECE	Tue	CR-20-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
430	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Tue	CR-20-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
431	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15C	ECE	Tue	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
432	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15C	ECE	Tue	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
433	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15C	ECE	Tue	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
434	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Tue	Control System Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
435	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Tue	Control System Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
436	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Tue	Control System Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
437	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Wed	CR-19-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
438	Dr. Nauman Anwar Baig	Digital Signal Processing	2K23-BEE-15C	ECE	Wed	DSP & Comm Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
439	Dr. Nauman Anwar Baig	Digital Signal Processing	2K23-BEE-15C	ECE	Wed	DSP & Comm Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
440	Dr. Nauman Anwar Baig	Digital Signal Processing	2K23-BEE-15C	ECE	Wed	DSP & Comm Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
441	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15C	ECE	Wed	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
442	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15C	ECE	Wed	EMS Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
443	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15C	ECE	Wed	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
444	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15C	ECE	Wed	EMS Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
445	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15C	ECE	Wed	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
446	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15C	ECE	Wed	EMS Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
447	Dr. Azad Akhtar Siddiqui	Numerical Methods	2K23-BEE-15D	H&S	Fri	CR-18-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
448	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Fri	CR-18-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
449	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Fri	CR-18-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
450	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Fri	CR-18-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
451	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Mon	Lecture Hall-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
452	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15D	ECE	Mon	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
453	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15D	ECE	Mon	CR-20-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
454	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15D	ECE	Mon	Lecture Hall-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
455	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15D	ECE	Mon	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
456	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15D	ECE	Mon	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
457	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15D	ECE	Mon	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
458	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Mon	DSP & Comm Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
459	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Mon	DSP & Comm Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
461	Dr. Azad Akhtar Siddiqui	Numerical Methods	2K23-BEE-15D	H&S	Thu	CR-18-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
462	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Thu	DSP & Comm Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
463	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Thu	DSP & Comm Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
464	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Thu	DSP & Comm Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
465	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Tue	Control System Lab	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
466	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Tue	Control System Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
467	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Tue	Control System Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
468	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15D	ECE	Tue	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
469	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15D	ECE	Tue	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
470	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15D	ECE	Tue	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
471	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Tue	CR-18-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
472	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Tue	CR-18-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
473	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Wed	CR-18-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
474	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Wed	CR-18-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
475	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Wed	CR-18-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
476	Dr. Azad Akhtar Siddiqui	Numerical Methods	2K23-BEE-15D	H&S	Wed	CR-18-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
477	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15D	ECE	Wed	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
478	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15D	ECE	Wed	EMS Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
479	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15D	ECE	Wed	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
480	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15D	ECE	Wed	EMS Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
481	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15D	ECE	Wed	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
482	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15D	ECE	Wed	EMS Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
483	Dr. Hasan Tahir Butt	Human Computer Interaction	2K23-BESE-14A	FoC	Fri	Computing Lab-11	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
484	Dr. Hasan Tahir Butt	Human Computer Interaction	2K23-BESE-14A	FoC	Fri	Computing Lab-11	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
485	Dr. Hasan Tahir Butt	Human Computer Interaction	2K23-BESE-14A	FoC	Fri	Computing Lab-11	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
486	Ms. Ayesha Kanwal	Software Project Management	2K23-BESE-14A	FoC	Fri	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
487	Dr. Hashir Moheed Kiyani	Machine Learning	2K23-BESE-14A	FoC	Mon	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
488	Dr. Hashir Moheed Kiyani	Machine Learning	2K23-BESE-14A	FoC	Mon	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
489	Dr. Hashir Moheed Kiyani	Machine Learning	2K23-BESE-14A	FoC	Mon	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
490	Ms. Ayesha Kanwal	Software Project Management	2K23-BESE-14A	FoC	Mon	CR-05-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
491	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14A	FoC	Thu	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
492	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14A	FoC	Thu	CR-23-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
493	Dr. Hashir Moheed Kiyani	Machine Learning	2K23-BESE-14A	FoC	Thu	CR-23-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
494	Dr. Hashir Moheed Kiyani	Machine Learning	2K23-BESE-14A	FoC	Thu	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
495	Ms. Ayesha Kanwal	Software Project Management	2K23-BESE-14A	FoC	Tue	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
496	Mr. Maajid Maqbool	Entrepreneurship	2K23-BESE-14A	FoC	Tue	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
497	Dr. Hasan Tahir Butt	Human Computer Interaction	2K23-BESE-14A	FoC	Tue	CR-23-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
498	Dr. Hasan Tahir Butt	Human Computer Interaction	2K23-BESE-14A	FoC	Tue	CR-23-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
499	Dr. Hashir Moheed Kiyani	Machine Learning	2K23-BESE-14A	FoC	Tue	CR-23-Acad Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
500	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14A	FoC	Wed	CR-23-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
501	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14A	FoC	Wed	CR-23-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
502	Mr. Maajid Maqbool	Entrepreneurship	2K23-BESE-14A	FoC	Wed	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
503	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14A	FoC	Wed	CR-23-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
504	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14A	FoC	Wed	CR-23-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
505	Ms. Ayesha Kanwal	Software Project Management	2K23-BESE-14B	FoC	Fri	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
506	Mr. Hamza Saleem	Human Computer Interaction	2K23-BESE-14B	FoC	Fri	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
507	Mr. Hamza Saleem	Human Computer Interaction	2K23-BESE-14B	FoC	Fri	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
508	Mr. Hamza Saleem	Human Computer Interaction	2K23-BESE-14B	FoC	Fri	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
509	Ms. Ayesha Kanwal	Software Project Management	2K23-BESE-14B	FoC	Mon	CR-24-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
510	Dr. Muhammad Daud Abdullah Asif	Machine Learning	2K23-BESE-14B	FoC	Mon	CR-24-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
511	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14B	FoC	Mon	CR-24-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
512	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14B	FoC	Mon	CR-24-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
513	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14B	FoC	Thu	CR-24-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
514	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14B	FoC	Thu	CR-24-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
515	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14B	FoC	Thu	CR-24-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
516	Mr. Hamza Saleem	Human Computer Interaction	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
517	Mr. Hamza Saleem	Human Computer Interaction	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
518	Mr. Maajid Maqbool	Entrepreneurship	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
519	Ms. Ayesha Kanwal	Software Project Management	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
520	Dr. Muhammad Daud Abdullah Asif	Machine Learning	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
521	Dr. Muhammad Daud Abdullah Asif	Machine Learning	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
522	Dr. Muhammad Daud Abdullah Asif	Machine Learning	2K23-BESE-14B	FoC	Wed	Computing Lab-10	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
523	Dr. Muhammad Daud Abdullah Asif	Machine Learning	2K23-BESE-14B	FoC	Wed	Computing Lab-10	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
524	Dr. Muhammad Daud Abdullah Asif	Machine Learning	2K23-BESE-14B	FoC	Wed	Computing Lab-10	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
525	Mr. Maajid Maqbool	Entrepreneurship	2K23-BESE-14B	FoC	Wed	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
526	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14B	FoC	Wed	CR-24-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
527	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Fri	Computing Lab-10	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
528	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Fri	Computing Lab-10	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
529	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Fri	Computing Lab-10	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
530	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13A	FoC	Fri	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
531	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13A	FoC	Fri	Computing Lab-01	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
532	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13A	FoC	Fri	Computing Lab-01	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
533	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13A	FoC	Fri	Computing Lab-01	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
534	Dr. Junaid Younas	Deep Learning	2K23-BSCS-13A	FoC	Mon	CR-25-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
535	Dr. Junaid Younas	Deep Learning	2K23-BSCS-13A	FoC	Mon	CR-25-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
536	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13A	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
537	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13A	FoC	Mon	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
538	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13A	FoC	Mon	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
539	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13A	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
540	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13A	FoC	Mon	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
541	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13A	FoC	Mon	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
542	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13A	FoC	Mon	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
543	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13A	FoC	Mon	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
544	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13A	FoC	Mon	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
545	Dr. Junaid Younas	Deep Learning	2K23-BSCS-13A	FoC	Thu	Computing Lab-02	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
546	Dr. Junaid Younas	Deep Learning	2K23-BSCS-13A	FoC	Thu	Computing Lab-02	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
547	Dr. Junaid Younas	Deep Learning	2K23-BSCS-13A	FoC	Thu	Computing Lab-02	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
548	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13A	FoC	Thu	CR-25-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
549	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13A	FoC	Thu	CR-25-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
550	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13A	FoC	Tue	Computing Lab-11	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
551	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13A	FoC	Tue	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
552	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13A	FoC	Tue	Computing Lab-11	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
553	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13A	FoC	Tue	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
554	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13A	FoC	Tue	Computing Lab-11	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	\N
555	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13A	FoC	Tue	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	\N
556	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13A	FoC	Tue	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
557	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13A	FoC	Tue	Computing Lab-12	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
558	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13A	FoC	Tue	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
559	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13A	FoC	Tue	Computing Lab-12	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
560	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13A	FoC	Tue	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
561	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13A	FoC	Tue	Computing Lab-12	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
562	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
563	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
564	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
565	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13A	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
566	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
567	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13A	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
568	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
569	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
570	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13B	FoC	Fri	CR-25-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
571	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13B	FoC	Fri	Computing Lab-01	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
572	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13B	FoC	Fri	Computing Lab-01	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
573	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13B	FoC	Fri	Computing Lab-01	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
574	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Fri	Computing Lab-10	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
575	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Fri	Computing Lab-10	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
576	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Fri	Computing Lab-10	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
577	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13B	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
578	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13B	FoC	Mon	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
579	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13B	FoC	Mon	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
580	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13B	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
581	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13B	FoC	Mon	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
582	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13B	FoC	Mon	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
583	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13B	FoC	Mon	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
584	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13B	FoC	Mon	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
585	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13B	FoC	Mon	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
586	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13B	FoC	Thu	CR-25-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
587	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13B	FoC	Thu	CR-25-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
588	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13B	FoC	Thu	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
589	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13B	FoC	Thu	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
590	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Thu	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
591	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Thu	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
592	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Thu	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
593	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13B	FoC	Tue	Computing Lab-11	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
594	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13B	FoC	Tue	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
595	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13B	FoC	Tue	Computing Lab-11	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
596	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13B	FoC	Tue	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
597	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13B	FoC	Tue	Computing Lab-11	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	\N
598	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13B	FoC	Tue	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	\N
599	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13B	FoC	Tue	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
600	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13B	FoC	Tue	Computing Lab-12	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
601	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13B	FoC	Tue	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
602	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13B	FoC	Tue	Computing Lab-12	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
603	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13B	FoC	Tue	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
604	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13B	FoC	Tue	Computing Lab-12	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
605	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Wed	CR-24-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
606	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Wed	CR-24-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
607	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13B	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
608	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13B	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
609	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13B	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
610	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13B	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
611	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Wed	CR-05-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
612	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Wed	CR-05-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
613	Dr. Shah Khalid	Parallel & Distributed Computing	2K23-BSCS-13C	FoC	Fri	CR-26-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
614	Dr. Shah Khalid	Parallel & Distributed Computing	2K23-BSCS-13C	FoC	Fri	CR-26-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
615	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13C	FoC	Fri	CR-26-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
616	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13C	FoC	Fri	CR-26-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
617	Dr. Mehwish Awan	Deep Learning	2K23-BSCS-13C	FoC	Fri	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
618	Dr. Mehwish Awan	Deep Learning	2K23-BSCS-13C	FoC	Fri	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
619	Dr. Mehwish Awan	Deep Learning	2K23-BSCS-13C	FoC	Fri	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
620	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13C	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
621	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13C	FoC	Mon	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
622	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13C	FoC	Mon	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
623	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13C	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
624	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13C	FoC	Mon	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
625	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13C	FoC	Mon	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
626	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13C	FoC	Mon	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
627	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13C	FoC	Mon	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
628	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13C	FoC	Mon	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
629	Dr. Shah Khalid	Parallel & Distributed Computing	2K23-BSCS-13C	FoC	Thu	Computing Lab-07	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
630	Dr. Shah Khalid	Parallel & Distributed Computing	2K23-BSCS-13C	FoC	Thu	Computing Lab-07	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
631	Dr. Shah Khalid	Parallel & Distributed Computing	2K23-BSCS-13C	FoC	Thu	Computing Lab-07	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
632	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13C	FoC	Thu	CR-26-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
633	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13C	ECE	Thu	Computing Lab-10	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
634	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13C	ECE	Thu	Computing Lab-10	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
635	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13C	ECE	Thu	Computing Lab-10	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
636	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13C	FoC	Tue	Computing Lab-11	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
637	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13C	FoC	Tue	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
638	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13C	FoC	Tue	Computing Lab-11	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
639	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13C	FoC	Tue	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
640	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13C	FoC	Tue	Computing Lab-11	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	\N
641	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13C	FoC	Tue	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	\N
642	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13C	FoC	Tue	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
643	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13C	FoC	Tue	Computing Lab-12	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
644	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13C	FoC	Tue	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
645	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13C	FoC	Tue	Computing Lab-12	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
646	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13C	FoC	Tue	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
647	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13C	FoC	Tue	Computing Lab-12	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
648	Dr. Mehwish Awan	Deep Learning	2K23-BSCS-13C	FoC	Wed	CR-28-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
649	Dr. Mehwish Awan	Deep Learning	2K23-BSCS-13C	FoC	Wed	CR-28-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
650	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13C	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
651	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13C	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
652	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13C	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
653	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13C	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
654	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13C	ECE	Wed	CR-26-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
655	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13C	ECE	Wed	CR-26-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
656	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13D	FoC	Fri	CR-23-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
657	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13D	FoC	Fri	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
658	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13D	FoC	Fri	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
659	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13D	FoC	Fri	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
660	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13D	ECE	Fri	CR-26-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
661	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13D	ECE	Fri	CR-26-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
662	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13D	FoC	Mon	CR-23-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
663	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13D	FoC	Mon	CR-23-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
664	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13D	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
665	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13D	FoC	Mon	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
666	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13D	FoC	Mon	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
667	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13D	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
668	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13D	FoC	Mon	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
669	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13D	FoC	Mon	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
670	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13D	FoC	Mon	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
671	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13D	FoC	Mon	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
672	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13D	FoC	Mon	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
673	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13D	ECE	Thu	Computing Lab-10	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
674	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13D	ECE	Thu	Computing Lab-10	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
675	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13D	ECE	Thu	Computing Lab-10	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
676	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13D	FoC	Thu	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
677	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13D	FoC	Thu	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
678	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13D	FoC	Thu	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
679	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13D	FoC	Tue	Computing Lab-11	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
680	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13D	FoC	Tue	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
681	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13D	FoC	Tue	Computing Lab-11	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
682	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13D	FoC	Tue	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
683	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13D	FoC	Tue	Computing Lab-11	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	\N
684	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13D	FoC	Tue	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	\N
685	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13D	FoC	Tue	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
686	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13D	FoC	Tue	Computing Lab-12	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
687	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13D	FoC	Tue	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
688	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13D	FoC	Tue	Computing Lab-12	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
689	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13D	FoC	Tue	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
690	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13D	FoC	Tue	Computing Lab-12	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
691	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13D	FoC	Wed	CR-26-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
692	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13D	FoC	Wed	CR-26-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
693	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13D	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
694	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13D	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
695	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13D	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
696	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13D	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
697	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13D	FoC	Wed	CR-27-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
698	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13D	FoC	Wed	CR-27-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
699	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Fri	CR-27-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
700	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Fri	CR-27-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
701	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13E	ECE	Fri	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
702	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13E	ECE	Fri	CR-28-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
703	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13E	FoC	Fri	Computing Lab-12	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
704	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13E	FoC	Fri	Computing Lab-12	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
705	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13E	FoC	Fri	Computing Lab-12	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
706	Dr. Sarosh Tahir	Software Engineering	2K23-BSCS-13E	FoC	Mon	CR-27-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
707	Dr. Sarosh Tahir	Software Engineering	2K23-BSCS-13E	FoC	Mon	CR-27-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
708	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13E	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
709	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13E	FoC	Mon	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
710	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13E	FoC	Mon	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
711	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13E	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
712	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13E	FoC	Mon	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
713	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13E	FoC	Mon	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
714	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13E	FoC	Mon	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
715	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13E	FoC	Mon	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
716	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13E	FoC	Mon	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
717	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Thu	Computing Lab-11	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
718	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Thu	Computing Lab-11	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
719	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Thu	Computing Lab-11	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
720	Dr. Sarosh Tahir	Software Engineering	2K23-BSCS-13E	FoC	Tue	CR-27-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
721	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13E	FoC	Tue	Computing Lab-11	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
722	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13E	FoC	Tue	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	\N
723	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13E	FoC	Tue	Computing Lab-11	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
724	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13E	FoC	Tue	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	\N
725	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13E	FoC	Tue	Computing Lab-11	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	\N
726	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13E	FoC	Tue	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	\N
727	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13E	FoC	Tue	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
728	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13E	FoC	Tue	Computing Lab-12	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	\N
729	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13E	FoC	Tue	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
730	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13E	FoC	Tue	Computing Lab-12	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	\N
731	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13E	FoC	Tue	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
732	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13E	FoC	Tue	Computing Lab-12	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	\N
733	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13E	FoC	Wed	CR-27-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
734	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13E	FoC	Wed	CR-27-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
735	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13E	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
736	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13E	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	\N
737	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13E	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
738	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13E	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	\N
739	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13E	ECE	Wed	Computing Lab-10	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
740	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13E	ECE	Wed	Computing Lab-10	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
741	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13E	ECE	Wed	Computing Lab-10	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
742	Dr. Nazia Pervaiz	Computer Vision	2K23-BSDS-1A	FoC	Fri	CR-28-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
743	Dr. Nazia Pervaiz	Computer Vision	2K23-BSDS-1A	FoC	Fri	CR-28-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
744	Ms. Sahar Arshad	Mobile Application Development	2K23-BSDS-1A	FoC	Fri	CR-28-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
745	Ms. Sahar Arshad	Mobile Application Development	2K23-BSDS-1A	FoC	Fri	CR-28-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
746	Dr. Muhammad Moazam Fraz	Large Language Models	2K23-BSDS-1A	FoC	Fri	Computing Lab-08	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
747	Dr. Muhammad Moazam Fraz	Large Language Models	2K23-BSDS-1A	FoC	Fri	Computing Lab-08	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
748	Dr. Muhammad Moazam Fraz	Large Language Models	2K23-BSDS-1A	FoC	Fri	Computing Lab-08	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
749	Dr. Fahad Ahmed Satti	Parallel & Distributed Computing	2K23-BSDS-1A	FoC	Mon	Computing Lab-10	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
750	Dr. Fahad Ahmed Satti	Parallel & Distributed Computing	2K23-BSDS-1A	FoC	Mon	Computing Lab-10	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
751	Dr. Fahad Ahmed Satti	Parallel & Distributed Computing	2K23-BSDS-1A	FoC	Mon	Computing Lab-10	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
752	Dr. Rabia Irfan	Data Warehousing and Business Intelligence	2K23-BSDS-1A	FoC	Mon	Computing Lab-10	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
753	Dr. Rabia Irfan	Data Warehousing and Business Intelligence	2K23-BSDS-1A	FoC	Mon	Computing Lab-10	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
754	Dr. Rabia Irfan	Data Warehousing and Business Intelligence	2K23-BSDS-1A	FoC	Mon	Computing Lab-10	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
755	Dr. Nazia Pervaiz	Computer Vision	2K23-BSDS-1A	FoC	Thu	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
756	Dr. Nazia Pervaiz	Computer Vision	2K23-BSDS-1A	FoC	Thu	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
757	Dr. Nazia Pervaiz	Computer Vision	2K23-BSDS-1A	FoC	Thu	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
758	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K23-BSDS-1A	H&S	Thu	CR-28-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
759	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K23-BSDS-1A	H&S	Thu	CR-28-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
760	Dr. Rabia Irfan	Data Warehousing and Business Intelligence	2K23-BSDS-1A	FoC	Tue	CR-28-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
761	Dr. Rabia Irfan	Data Warehousing and Business Intelligence	2K23-BSDS-1A	FoC	Tue	CR-28-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
762	Dr. Fahad Ahmed Satti	Parallel & Distributed Computing	2K23-BSDS-1A	FoC	Tue	CR-28-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
763	Dr. Fahad Ahmed Satti	Parallel & Distributed Computing	2K23-BSDS-1A	FoC	Tue	CR-28-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
764	Ms. Sahar Arshad	Mobile Application Development	2K23-BSDS-1A	FoC	Wed	Computing Lab-07	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
765	Ms. Sahar Arshad	Mobile Application Development	2K23-BSDS-1A	FoC	Wed	Computing Lab-07	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
766	Ms. Sahar Arshad	Mobile Application Development	2K23-BSDS-1A	FoC	Wed	Computing Lab-07	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
767	Dr. Muhammad Moazam Fraz	Large Language Models	2K23-BSDS-1A	FoC	Wed	CR-28-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
768	Dr. Muhammad Moazam Fraz	Large Language Models	2K23-BSDS-1A	FoC	Wed	CR-28-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
769	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Mon	CR-05-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
770	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16A	H&S	Mon	CR-05-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
771	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16A	H&S	Mon	CR-05-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
772	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Mon	Adv Electronics Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
773	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Mon	Adv Electronics Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
774	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Mon	Adv Electronics Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
775	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16A	ECE	Thu	Embedded Systems Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
776	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16A	ECE	Thu	Embedded Systems Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
777	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16A	ECE	Thu	Embedded Systems Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
778	Dr. Salman Abdul Ghafoor	Electromagnetic Field Theory	2K24-BEE-16A	ECE	Thu	CR-05-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
779	Dr. Salman Abdul Ghafoor	Electromagnetic Field Theory	2K24-BEE-16A	ECE	Thu	CR-05-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
780	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16A	H&S	Tue	CR-05-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
781	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Tue	CR-05-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
782	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Tue	CR-05-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
783	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16A	ECE	Tue	CR-05-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
784	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16A	H&S	Tue	CR-05-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
785	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16A	H&S	Tue	CR-05-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
786	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16A	ECE	Wed	CR-05-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
787	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16A	ECE	Wed	CR-05-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
788	Dr. Salman Abdul Ghafoor	Electromagnetic Field Theory	2K24-BEE-16A	ECE	Wed	CR-05-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
789	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16A	H&S	Wed	CR-06-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
790	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16B	ECE	Mon	Adv Electronics Lab	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
791	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16B	ECE	Mon	Adv Electronics Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
792	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16B	ECE	Mon	Adv Electronics Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
793	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16B	H&S	Mon	CR-15-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
794	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16B	H&S	Mon	CR-06-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
795	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16B	H&S	Mon	CR-06-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
796	Dr. Muhammad Mustafa Tahseen	Electromagnetic Field Theory	2K24-BEE-16B	ECE	Mon	CR-06-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
797	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Thu	CR-06-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
798	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Thu	CR-06-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
799	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Thu	Embedded Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
800	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Thu	Embedded Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
801	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Thu	Embedded Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
802	Dr. Muhammad Mustafa Tahseen	Electromagnetic Field Theory	2K24-BEE-16B	ECE	Tue	CR-06-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
803	Dr. Muhammad Mustafa Tahseen	Electromagnetic Field Theory	2K24-BEE-16B	ECE	Tue	CR-06-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
804	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16B	H&S	Tue	CR-06-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
805	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16B	H&S	Tue	CR-06-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
806	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Tue	CR-06-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
807	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16B	ECE	Tue	CR-06-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
808	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16B	H&S	Wed	CR-06-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
809	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16B	ECE	Wed	CR-06-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
810	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16B	ECE	Wed	CR-06-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
811	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16C	H&S	Mon	CR-07-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
812	Dr. Wasif Tanveer	Electromagnetic Field Theory	2K24-BEE-16C	ECE	Mon	CR-07-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
813	Dr. Wasif Tanveer	Electromagnetic Field Theory	2K24-BEE-16C	ECE	Mon	CR-07-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
814	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16C	H&S	Mon	CR-07-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
815	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16C	H&S	Mon	CR-07-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
816	Dr. Muhammad Saad Zia	Electronic Circuit Design	2K24-BEE-16C	ECE	Thu	CR-07-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
817	Dr. Muhammad Saad Zia	Electronic Circuit Design	2K24-BEE-16C	ECE	Thu	CR-07-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
818	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16C	ECE	Thu	CR-07-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
819	Dr. Muhammad Saad Zia	Electronic Circuit Design	2K24-BEE-16C	ECE	Thu	Adv Electronics Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
820	Dr. Muhammad Saad Zia	Electronic Circuit Design	2K24-BEE-16C	ECE	Thu	Adv Electronics Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
821	Dr. Muhammad Saad Zia	Electronic Circuit Design	2K24-BEE-16C	ECE	Thu	Adv Electronics Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
822	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16C	H&S	Tue	CR-07-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
823	Dr. Muhammad Saad Zia	Electronic Circuit Design	2K24-BEE-16C	ECE	Tue	CR-07-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
824	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16C	ECE	Tue	Embedded Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
825	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16C	ECE	Tue	Embedded Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
826	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16C	ECE	Tue	Embedded Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
827	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16C	H&S	Wed	CR-07-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
828	Dr. Wasif Tanveer	Electromagnetic Field Theory	2K24-BEE-16C	ECE	Wed	CR-07-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
829	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16C	H&S	Wed	CR-07-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
830	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16C	ECE	Wed	CR-07-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
831	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16C	ECE	Wed	CR-07-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
832	Dr. Attique Dawood	Electromagnetic Field Theory	2K24-BEE-16D	ECE	Mon	CR-08-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
833	Dr. Attique Dawood	Electromagnetic Field Theory	2K24-BEE-16D	ECE	Mon	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
834	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Mon	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
835	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16D	ECE	Mon	CR-08-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
836	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16D	ECE	Mon	CR-08-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
837	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16D	H&S	Mon	CR-08-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
838	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Thu	Adv Electronics Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
839	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Thu	Adv Electronics Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
840	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Thu	Adv Electronics Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
841	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16D	ECE	Thu	CR-08-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
842	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Thu	CR-08-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
843	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Tue	CR-08-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
844	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16D	ECE	Tue	Embedded Systems Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
845	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16D	ECE	Tue	Embedded Systems Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
846	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16D	ECE	Tue	Embedded Systems Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
847	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Tue	CR-08-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
848	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Tue	CR-08-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
849	Dr. Attique Dawood	Electromagnetic Field Theory	2K24-BEE-16D	ECE	Wed	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
850	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Wed	CR-08-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
851	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16D	H&S	Wed	CR-08-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
852	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16D	H&S	Wed	CR-08-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
853	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Fri	Computing Lab-04	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
854	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Fri	Computing Lab-04	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
855	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Fri	Computing Lab-04	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
856	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15A	H&S	Mon	CR-17-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
857	Ms. Ansar Shahzadi	Probability and Statistics	2K24-BESE-15A	H&S	Mon	CR-16-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
858	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Mon	Computing Lab-04	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
859	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Mon	Computing Lab-04	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
860	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Mon	Computing Lab-04	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
861	Ms. Ansar Shahzadi	Probability and Statistics	2K24-BESE-15A	H&S	Thu	CR-17-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
862	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Thu	CR-16-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
863	Dr. Zuhair Zafar	Design & Analysis of Algorithm	2K24-BESE-15A	FoC	Thu	CR-16-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
864	Ms. Ansar Shahzadi	Probability and Statistics	2K24-BESE-15A	H&S	Tue	CR-16-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
865	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15A	H&S	Tue	CR-16-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
866	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Tue	CR-16-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
867	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Tue	CR-16-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
868	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Tue	CR-16-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
869	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Tue	CR-16-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
870	Dr. Oumar Saleem	Islamic Studies	2K24-BESE-15A	H&S	Wed	CR-16-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
871	Dr. Oumar Saleem	Islamic Studies	2K24-BESE-15A	H&S	Wed	CR-16-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
872	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15A	H&S	Wed	CR-16-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
873	Dr. Zuhair Zafar	Design & Analysis of Algorithm	2K24-BESE-15A	FoC	Wed	CR-16-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
874	Dr. Zuhair Zafar	Design & Analysis of Algorithm	2K24-BESE-15A	FoC	Wed	CR-16-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
875	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Fri	Computing Lab-04	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
876	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Fri	Computing Lab-04	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
877	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Fri	Computing Lab-04	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
878	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15B	H&S	Mon	CR-17-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
879	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Mon	Computing Lab-04	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
880	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Mon	Computing Lab-04	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
881	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Mon	Computing Lab-04	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
882	Ms. Ansar Shahzadi	Probability and Statistics	2K24-BESE-15B	H&S	Mon	CR-15-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
883	Ms. Ansar Shahzadi	Probability and Statistics	2K24-BESE-15B	H&S	Thu	CR-17-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
884	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Thu	CR-17-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
885	Dr. Aimal Tariq Rextin	Design & Analysis of Algorithm	2K24-BESE-15B	FoC	Thu	CR-17-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
886	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15B	H&S	Tue	CR-17-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
887	Ms. Ansar Shahzadi	Probability and Statistics	2K24-BESE-15B	H&S	Tue	CR-17-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
888	Dr. Oumar Saleem	Islamic Studies	2K24-BESE-15B	H&S	Tue	CR-17-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
889	Dr. Oumar Saleem	Islamic Studies	2K24-BESE-15B	H&S	Tue	CR-17-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
890	Dr. Aimal Tariq Rextin	Design & Analysis of Algorithm	2K24-BESE-15B	FoC	Tue	CR-17-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
891	Dr. Aimal Tariq Rextin	Design & Analysis of Algorithm	2K24-BESE-15B	FoC	Tue	CR-17-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
892	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15B	H&S	Wed	CR-17-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
893	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Wed	CR-17-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
894	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Wed	CR-17-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
895	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Wed	CR-17-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
896	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Wed	CR-17-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
897	Dr. Naima Iltaaf	Web Technologies	2K24-BSAI-1A	FoC	Fri	Computing Lab-08	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
898	Dr. Naima Iltaaf	Web Technologies	2K24-BSAI-1A	FoC	Fri	Computing Lab-08	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
899	Dr. Naima Iltaaf	Web Technologies	2K24-BSAI-1A	FoC	Fri	Computing Lab-08	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
900	Dr. Samia Tahir	Expository Writing	2K24-BSAI-1A	H&S	Mon	CR-11-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
901	Ms. Tabassam Gul	Computer Organization & Assembly Language	2K24-BSAI-1A	ECE	Mon	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
902	Ms. Tabassam Gul	Computer Organization & Assembly Language	2K24-BSAI-1A	ECE	Mon	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
903	Dr. Mehwish Fatima	Programming for AI	2K24-BSAI-1A	FoC	Mon	CR-23-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
904	Dr. Mehwish Fatima	Programming for AI	2K24-BSAI-1A	FoC	Mon	CR-23-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
905	Dr. Samia Tahir	Expository Writing	2K24-BSAI-1A	H&S	Thu	CR-11-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
906	Dr. Naima Iltaaf	Web Technologies	2K24-BSAI-1A	FoC	Thu	CR-11-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
907	Dr. Naima Iltaaf	Web Technologies	2K24-BSAI-1A	FoC	Thu	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
908	Dr. Sidra Shafiq	Applied Physics	2K24-BSAI-1A	H&S	Thu	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
909	Dr. Seemab Latif	Machine Learning	2K24-BSAI-1A	FoC	Thu	Computing Lab-04	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
910	Dr. Seemab Latif	Machine Learning	2K24-BSAI-1A	FoC	Thu	Computing Lab-04	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
911	Dr. Seemab Latif	Machine Learning	2K24-BSAI-1A	FoC	Thu	Computing Lab-04	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
912	Dr. Samia Tahir	Expository Writing	2K24-BSAI-1A	H&S	Tue	CR-06-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
913	Dr. Mehwish Fatima	Programming for AI	2K24-BSAI-1A	FoC	Tue	Computing Lab-04	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
914	Dr. Mehwish Fatima	Programming for AI	2K24-BSAI-1A	FoC	Tue	Computing Lab-04	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
915	Dr. Mehwish Fatima	Programming for AI	2K24-BSAI-1A	FoC	Tue	Computing Lab-04	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
916	Dr. Seemab Latif	Machine Learning	2K24-BSAI-1A	FoC	Tue	CR-07-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
917	Dr. Seemab Latif	Machine Learning	2K24-BSAI-1A	FoC	Tue	CR-07-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
918	Dr. Sidra Shafiq	Applied Physics	2K24-BSAI-1A	H&S	Wed	CR-11-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
919	Ms. Tabassam Gul	Computer Organization & Assembly Language	2K24-BSAI-1A	ECE	Wed	Adv Electronics Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
920	Ms. Tabassam Gul	Computer Organization & Assembly Language	2K24-BSAI-1A	ECE	Wed	Adv Electronics Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
921	Ms. Tabassam Gul	Computer Organization & Assembly Language	2K24-BSAI-1A	ECE	Wed	Adv Electronics Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
922	Dr. Sidra Shafiq	Applied Physics	2K24-BSAI-1A	H&S	Wed	Physics Lab 01-SNS	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
923	Dr. Sidra Shafiq	Applied Physics	2K24-BSAI-1A	H&S	Wed	Physics Lab 01-SNS	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
924	Dr. Sidra Shafiq	Applied Physics	2K24-BSAI-1A	H&S	Wed	Physics Lab 01-SNS	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
925	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14A	H&S	Fri	CR-21-SMRIMMS	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
926	Dr. Muhammad Bilal Ali	Advanced Database Management Systems	2K24-BSCS-14A	FoC	Fri	Computing Lab-06	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
927	Dr. Muhammad Bilal Ali	Advanced Database Management Systems	2K24-BSCS-14A	FoC	Fri	Computing Lab-06	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
928	Dr. Muhammad Bilal Ali	Advanced Database Management Systems	2K24-BSCS-14A	FoC	Fri	Computing Lab-06	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
929	Dr. Muhammad Bilal Ali	Advanced Database Management Systems	2K24-BSCS-14A	FoC	Mon	CR-21-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
930	Dr. Muhammad Bilal Ali	Advanced Database Management Systems	2K24-BSCS-14A	FoC	Mon	CR-21-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
931	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14A	FoC	Mon	CR-21-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
932	Dr. Qaiser Riaz	Web Technologies	2K24-BSCS-14A	FoC	Mon	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
933	Dr. Qaiser Riaz	Web Technologies	2K24-BSCS-14A	FoC	Mon	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
934	Dr. Qaiser Riaz	Web Technologies	2K24-BSCS-14A	FoC	Mon	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
935	Dr. Imran Malik	Applied Physics	2K24-BSCS-14A	H&S	Thu	Physics Lab 01-SNS	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
936	Dr. Imran Malik	Applied Physics	2K24-BSCS-14A	H&S	Thu	Physics Lab 01-SNS	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
937	Dr. Imran Malik	Applied Physics	2K24-BSCS-14A	H&S	Thu	Physics Lab 01-SNS	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
938	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14A	H&S	Thu	CR-21-SMRIMMS	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
939	Dr. Imran Malik	Applied Physics	2K24-BSCS-14A	H&S	Thu	CR-21-SMRIMMS	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
940	Dr. Qaiser Riaz	Web Technologies	2K24-BSCS-14A	FoC	Tue	CR-21-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
941	Dr. Qaiser Riaz	Web Technologies	2K24-BSCS-14A	FoC	Tue	CR-21-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
942	Dr. Imran Malik	Applied Physics	2K24-BSCS-14A	H&S	Tue	CR-21-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
943	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14A	FoC	Tue	CR-21-SMRIMMS	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
944	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14A	FoC	Tue	CR-21-SMRIMMS	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
945	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14A	FoC	Wed	Control System Lab	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
946	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14A	FoC	Wed	Control System Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
947	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14A	FoC	Wed	Control System Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
948	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14A	H&S	Wed	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
949	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14A	FoC	Wed	CR-21-SMRIMMS	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
950	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14A	FoC	Wed	CR-21-SMRIMMS	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
951	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14B	H&S	Fri	CR-21-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
952	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14B	FoC	Fri	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
953	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14B	FoC	Fri	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
954	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14B	FoC	Fri	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
955	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Mon	CR-21-SMRIMMS	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
956	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14B	FoC	Mon	Computing Lab-06	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
957	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14B	FoC	Mon	Computing Lab-06	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
958	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14B	FoC	Mon	Computing Lab-06	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
959	Dr. Imran Malik	Applied Physics	2K24-BSCS-14B	H&S	Thu	CR-21-SMRIMMS	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
960	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14B	H&S	Thu	CR-21-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
961	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14B	FoC	Thu	CR-21-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
962	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14B	FoC	Thu	CR-21-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
963	Dr. Imran Malik	Applied Physics	2K24-BSCS-14B	H&S	Thu	Physics Lab 01-SNS	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
964	Dr. Imran Malik	Applied Physics	2K24-BSCS-14B	H&S	Thu	Physics Lab 01-SNS	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
965	Dr. Imran Malik	Applied Physics	2K24-BSCS-14B	H&S	Thu	Physics Lab 01-SNS	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
966	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14B	FoC	Tue	CR-18-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
967	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14B	FoC	Tue	CR-18-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
968	Dr. Imran Malik	Applied Physics	2K24-BSCS-14B	H&S	Tue	CR-18-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
969	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14B	FoC	Tue	Lecture Hall-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
970	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14B	FoC	Tue	Lecture Hall-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
971	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14B	H&S	Wed	CR-21-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
972	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Wed	CR-21-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
973	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Wed	CR-21-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
974	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14B	FoC	Wed	Control System Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
975	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14B	FoC	Wed	Control System Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
976	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14B	FoC	Wed	Control System Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
977	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14C	ECE	Fri	Adv Electronics Lab	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
978	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14C	ECE	Fri	Adv Electronics Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
979	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14C	ECE	Fri	Adv Electronics Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
980	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14C	H&S	Fri	CR-21-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
981	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Mon	CR-18-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
982	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Mon	CR-18-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
983	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Mon	CR-18-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
984	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14C	H&S	Thu	CR-22-SMRIMMS	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
985	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14C	ECE	Thu	CR-22-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
986	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14C	ECE	Thu	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
987	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14C	H&S	Thu	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
988	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14C	FoC	Thu	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
989	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14C	FoC	Thu	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
990	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14C	FoC	Thu	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
991	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14C	H&S	Tue	Physics Lab 01-SNS	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
992	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14C	H&S	Tue	Physics Lab 01-SNS	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
993	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14C	H&S	Tue	Physics Lab 01-SNS	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
994	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Tue	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
995	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Tue	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
996	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Tue	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
997	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14C	FoC	Wed	CR-22-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
998	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14C	FoC	Wed	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
999	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14C	H&S	Wed	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1000	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14C	H&S	Wed	CR-22-SMRIMMS	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1001	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Wed	CR-22-SMRIMMS	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1002	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Wed	CR-22-SMRIMMS	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
1003	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14D	H&S	Fri	CR-22-SMRIMMS	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1004	Dr. Samia Tahir	Expository Writing	2K24-BSCS-14D	H&S	Fri	CR-22-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1005	Dr. Sohail Iqbal	Theory of Automata	2K24-BSCS-14D	FoC	Fri	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1006	Dr. Sohail Iqbal	Theory of Automata	2K24-BSCS-14D	FoC	Fri	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1007	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14D	ECE	Fri	Adv Electronics Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1008	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14D	ECE	Fri	Adv Electronics Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1009	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14D	ECE	Fri	Adv Electronics Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1010	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Mon	CR-22-SMRIMMS	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1011	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Mon	CR-22-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1012	Dr. Sohail Iqbal	Theory of Automata	2K24-BSCS-14D	FoC	Mon	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1013	Dr. Samia Tahir	Expository Writing	2K24-BSCS-14D	H&S	Mon	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1014	Dr. Naima Iltaaf	Web Technologies	2K24-BSCS-14D	FoC	Mon	CR-20-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1015	Dr. Naima Iltaaf	Web Technologies	2K24-BSCS-14D	FoC	Mon	CR-20-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1016	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Thu	Computing Lab-06	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
1017	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Thu	Computing Lab-06	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1018	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Thu	Computing Lab-06	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1019	Dr. Samia Tahir	Expository Writing	2K24-BSCS-14D	H&S	Thu	CR-18-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1020	Dr. Naima Iltaaf	Web Technologies	2K24-BSCS-14D	FoC	Tue	Computing Lab-06	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1021	Dr. Naima Iltaaf	Web Technologies	2K24-BSCS-14D	FoC	Tue	Computing Lab-06	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1022	Dr. Naima Iltaaf	Web Technologies	2K24-BSCS-14D	FoC	Tue	Computing Lab-06	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1023	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14D	H&S	Tue	Physics Lab 01-SNS	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1024	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14D	H&S	Tue	Physics Lab 01-SNS	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1025	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14D	H&S	Tue	Physics Lab 01-SNS	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1026	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14D	ECE	Wed	Lecture Hall-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1027	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14D	ECE	Wed	Lecture Hall-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1028	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14D	H&S	Wed	Lecture Hall-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1029	Dr. Samia Tahir	Expository Writing	2K24-BSDS-2A	H&S	Fri	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1030	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Fri	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1031	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Fri	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1032	Dr. Samia Tahir	Expository Writing	2K24-BSDS-2A	H&S	Mon	CR-11-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1033	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Mon	Control System Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1034	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Mon	Control System Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1035	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Mon	Control System Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1036	Ms. Ansar Shahzadi	Advanced Statistics	2K24-BSDS-2A	H&S	Mon	CR-12-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1037	Dr. Rabia Irfan	Introduction to Data Science	2K24-BSDS-2A	FoC	Mon	CR-12-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1038	Dr. Rabia Irfan	Introduction to Data Science	2K24-BSDS-2A	FoC	Mon	CR-12-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
1039	Dr. Nazia Pervaiz	Machine Learning	2K24-BSDS-2A	FoC	Thu	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1040	Dr. Nazia Pervaiz	Machine Learning	2K24-BSDS-2A	FoC	Thu	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1041	Dr. Samia Tahir	Expository Writing	2K24-BSDS-2A	H&S	Thu	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1042	Ms. Ansar Shahzadi	Advanced Statistics	2K24-BSDS-2A	H&S	Thu	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1043	Dr. Imran Malik	Applied Physics	2K24-BSDS-2A	H&S	Thu	CR-14-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1044	Dr. Imran Malik	Applied Physics	2K24-BSDS-2A	H&S	Tue	CR-10-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1045	Dr. Rabia Irfan	Introduction to Data Science	2K24-BSDS-2A	FoC	Tue	Computing Lab-03	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1046	Dr. Rabia Irfan	Introduction to Data Science	2K24-BSDS-2A	FoC	Tue	Computing Lab-03	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1047	Dr. Rabia Irfan	Introduction to Data Science	2K24-BSDS-2A	FoC	Tue	Computing Lab-03	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1048	Ms. Ansar Shahzadi	Advanced Statistics	2K24-BSDS-2A	H&S	Tue	Computing Lab-08	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1049	Ms. Ansar Shahzadi	Advanced Statistics	2K24-BSDS-2A	H&S	Tue	Computing Lab-08	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1050	Ms. Ansar Shahzadi	Advanced Statistics	2K24-BSDS-2A	H&S	Tue	Computing Lab-08	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1051	Dr. Imran Malik	Applied Physics	2K24-BSDS-2A	H&S	Wed	Physics Lab 01-SNS	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1052	Dr. Imran Malik	Applied Physics	2K24-BSDS-2A	H&S	Wed	Physics Lab 01-SNS	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1053	Dr. Imran Malik	Applied Physics	2K24-BSDS-2A	H&S	Wed	Physics Lab 01-SNS	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1054	Dr. Nazia Pervaiz	Machine Learning	2K24-BSDS-2A	FoC	Wed	Computing Lab-08	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1055	Dr. Nazia Pervaiz	Machine Learning	2K24-BSDS-2A	FoC	Wed	Computing Lab-08	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1056	Dr. Nazia Pervaiz	Machine Learning	2K24-BSDS-2A	FoC	Wed	Computing Lab-08	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1057	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K25-BCE-1A	H&S	Fri	CR-13-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1058	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K25-BCE-1A	H&S	Fri	CR-13-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1059	Dr. Sadiq Amin	Fundamentals of Programming	2K25-BCE-1A	ECE	Mon	Computing Lab-01	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
1060	Dr. Sadiq Amin	Fundamentals of Programming	2K25-BCE-1A	ECE	Mon	Computing Lab-01	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1061	Dr. Sadiq Amin	Fundamentals of Programming	2K25-BCE-1A	ECE	Mon	Computing Lab-01	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1062	Dr. Sadiq Amin	Fundamentals of Programming	2K25-BCE-1A	ECE	Mon	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1063	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BCE-1A	H&S	Mon	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1064	Dr. Ahmed Naeem	Logic and Sequential Circuit Design	2K25-BCE-1A	ECE	Mon	CR-13-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1065	Dr. Ahmed Naeem	Logic and Sequential Circuit Design	2K25-BCE-1A	ECE	Mon	CR-13-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
1066	Dr. Fahd Sikandar Khan	Electrical Network Analysis	2K25-BCE-1A	FoC	Thu	Basic Electronics Lab	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
1067	Dr. Fahd Sikandar Khan	Electrical Network Analysis	2K25-BCE-1A	FoC	Thu	Basic Electronics Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1068	Dr. Fahd Sikandar Khan	Electrical Network Analysis	2K25-BCE-1A	FoC	Thu	Basic Electronics Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1069	Dr. Fahd Sikandar Khan	Electrical Network Analysis	2K25-BCE-1A	FoC	Thu	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1070	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1071	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1072	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1073	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1074	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1075	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1076	Dr. Ahmed Naeem	Logic and Sequential Circuit Design	2K25-BCE-1A	ECE	Tue	CR-13-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1077	Dr. Fahd Sikandar Khan	Electrical Network Analysis	2K25-BCE-1A	FoC	Tue	CR-13-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1078	Dr. Fahd Sikandar Khan	Electrical Network Analysis	2K25-BCE-1A	FoC	Tue	CR-13-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1079	Dr. Sadiq Amin	Fundamentals of Programming	2K25-BCE-1A	ECE	Tue	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1080	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BCE-1A	H&S	Tue	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1081	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BCE-1A	H&S	Wed	CR-13-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1082	Dr. Ahmed Naeem	Logic and Sequential Circuit Design	2K25-BCE-1A	ECE	Wed	Digital Systems Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1083	Dr. Ahmed Naeem	Logic and Sequential Circuit Design	2K25-BCE-1A	ECE	Wed	Digital Systems Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1084	Dr. Ahmed Naeem	Logic and Sequential Circuit Design	2K25-BCE-1A	ECE	Wed	Digital Systems Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1085	Mr. Jamil Ahmad	Workshop Practice	2K25-BCE-1A	ECE	Wed	MRC Lab 01- SMME	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1086	Mr. Jamil Ahmad	Workshop Practice	2K25-BCE-1A	ECE	Wed	MRC Lab 01- SMME	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1087	Mr. Jamil Ahmad	Workshop Practice	2K25-BCE-1A	ECE	Wed	MRC Lab 01- SMME	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1088	Dr. Sadiq Amin	Computer Programming	2K25-BEE-17A	ECE	Fri	CR-05-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1089	Dr. Azad Akhtar Siddiqui	Differential Equations	2K25-BEE-17A	H&S	Fri	CR-05-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1090	Mr. Saif Ullah	Understanding of Quran II	2K25-BEE-17A	H&S	Fri	CR-14-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1091	Mr. Saif Ullah	Understanding of Quran II	2K25-BEE-17A	H&S	Fri	CR-14-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1092	Mr. Saif Ullah	Understanding of Quran II	2K25-BEE-17A	H&S	Fri	CR-14-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1093	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Mon	CR-14-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1094	Dr. Sadiq Amin	Computer Programming	2K25-BEE-17A	ECE	Mon	Computing Lab-08	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1095	Dr. Sadiq Amin	Computer Programming	2K25-BEE-17A	ECE	Mon	Computing Lab-08	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1096	Dr. Sadiq Amin	Computer Programming	2K25-BEE-17A	ECE	Mon	Computing Lab-08	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1097	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17A	ECE	Thu	MRC Lab 01- SMME	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1098	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17A	ECE	Thu	MRC Lab 01- SMME	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1099	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17A	ECE	Thu	MRC Lab 01- SMME	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1100	Dr. Azad Akhtar Siddiqui	Differential Equations	2K25-BEE-17A	H&S	Thu	CR-14-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1101	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17A	H&S	Tue	CR-14-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1102	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Tue	Basic Electronics Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1103	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Tue	Basic Electronics Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1104	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Tue	Basic Electronics Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1105	Dr. Sadiq Amin	Computer Programming	2K25-BEE-17A	ECE	Tue	CR-14-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1106	Dr. Sadiq Amin	Computer Programming	2K25-BEE-17A	ECE	Tue	CR-14-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
1107	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17A	H&S	Wed	CR-14-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1108	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17A	H&S	Wed	CR-14-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1109	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17A	H&S	Wed	CR-14-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1110	Dr. Azad Akhtar Siddiqui	Differential Equations	2K25-BEE-17A	H&S	Wed	CR-14-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1111	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Wed	CR-14-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1112	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Wed	CR-14-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
1113	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BEE-17B	H&S	Fri	CR-14-UG Block	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
1114	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BEE-17B	H&S	Fri	CR-14-UG Block	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1115	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BEE-17B	H&S	Fri	CR-14-UG Block	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1116	Dr. Azad Akhtar Siddiqui	Differential Equations	2K25-BEE-17B	H&S	Fri	CR-14-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1117	Mr. Hassan Jamil	Computer Programming	2K25-BEE-17B	FoC	Mon	Computing Lab-08	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1118	Mr. Hassan Jamil	Computer Programming	2K25-BEE-17B	FoC	Mon	Computing Lab-08	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1119	Mr. Hassan Jamil	Computer Programming	2K25-BEE-17B	FoC	Mon	Computing Lab-08	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1120	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Mon	CR-14-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1121	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Mon	CR-14-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1122	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17B	H&S	Thu	CR-14-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1123	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17B	H&S	Thu	CR-14-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1124	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17B	H&S	Thu	CR-14-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1125	Dr. Azad Akhtar Siddiqui	Differential Equations	2K25-BEE-17B	H&S	Thu	CR-14-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1126	Mr. Hassan Jamil	Computer Programming	2K25-BEE-17B	FoC	Thu	CR-10-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1127	Mr. Hassan Jamil	Computer Programming	2K25-BEE-17B	FoC	Thu	CR-10-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1128	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17B	H&S	Tue	CR-08-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1129	Mr. Hassan Jamil	Computer Programming	2K25-BEE-17B	FoC	Tue	CR-14-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1130	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Tue	Basic Electronics Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1131	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Tue	Basic Electronics Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1132	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Tue	Basic Electronics Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1133	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17B	ECE	Wed	MRC Lab 01- SMME	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1134	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17B	ECE	Wed	MRC Lab 01- SMME	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1135	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17B	ECE	Wed	MRC Lab 01- SMME	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1136	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Wed	CR-13-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1137	Dr. Azad Akhtar Siddiqui	Differential Equations	2K25-BEE-17B	H&S	Wed	CR-13-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1138	Dr. Ibrar Hussain	Differential Equations	2k25-BEE-17C	H&S	Fri	CR-15-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1139	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	FoC	Fri	CR-15-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1140	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	CR-28-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1141	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	CR-28-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1142	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	Basic Electronics Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1143	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	Basic Electronics Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1144	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	Basic Electronics Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1145	Mr. Salman Mushtaq	Understanding of Quran II	2k25-BEE-17C	H&S	Thu	CR-15-UG Block	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
1146	Mr. Salman Mushtaq	Understanding of Quran II	2k25-BEE-17C	H&S	Thu	CR-15-UG Block	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1147	Mr. Salman Mushtaq	Understanding of Quran II	2k25-BEE-17C	H&S	Thu	CR-15-UG Block	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1148	Mr. Ammar Ahmed	Islamic Studies	2k25-BEE-17C	H&S	Thu	CR-15-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1149	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2k25-BEE-17C	H&S	Thu	CR-15-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1150	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2k25-BEE-17C	H&S	Thu	CR-15-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1151	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	FoC	Tue	CR-15-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1152	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	FoC	Tue	CR-15-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1153	Mr. Ammar Ahmed	Islamic Studies	2k25-BEE-17C	H&S	Tue	CR-15-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1154	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Tue	CR-15-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1155	Dr. Ibrar Hussain	Differential Equations	2k25-BEE-17C	H&S	Tue	CR-15-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1156	Dr. Ibrar Hussain	Differential Equations	2k25-BEE-17C	H&S	Tue	CR-15-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1157	Mr. Jamil Ahmad	Workshop Practice	2k25-BEE-17C	ECE	Wed	MRC Lab 01- SMME	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1158	Mr. Jamil Ahmad	Workshop Practice	2k25-BEE-17C	ECE	Wed	MRC Lab 01- SMME	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1159	Mr. Jamil Ahmad	Workshop Practice	2k25-BEE-17C	ECE	Wed	MRC Lab 01- SMME	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1160	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	FoC	Wed	Computing Lab-07	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1161	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	FoC	Wed	Computing Lab-07	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1162	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	FoC	Wed	Computing Lab-07	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1163	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Fri	CR-15-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1164	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Fri	Computing Lab-07	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1165	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Fri	Computing Lab-07	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1166	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Fri	Computing Lab-07	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1167	Mr. Habeel Ahmed	Electrical Network Analysis	2K25-BEE-17D	ECE	Mon	Basic Electronics Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1168	Mr. Habeel Ahmad	Electrical Network Analysis	2K25-BEE-17D	ECE	Mon	Basic Electronics Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1169	Mr. Habeel Ahmad	Electrical Network Analysis	2K25-BEE-17D	ECE	Mon	Basic Electronics Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1170	Dr. Hina Munir Dutt	Differential Equations	2K25-BEE-17D	H&S	Mon	CR-15-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1171	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17D	ECE	Thu	MRC Lab 01- SMME	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1172	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17D	ECE	Thu	MRC Lab 01- SMME	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1173	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17D	ECE	Thu	MRC Lab 01- SMME	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1174	Mr. Saif Ullah	Understanding of Quran II	2K25-BEE-17D	H&S	Thu	CR-11-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1175	Mr. Saif Ullah	Understanding of Quran II	2K25-BEE-17D	H&S	Thu	CR-11-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1176	Mr. Saif Ullah	Understanding of Quran II	2K25-BEE-17D	H&S	Thu	CR-11-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1177	Mr. Habeel Ahmad	Electrical Network Analysis	2K25-BEE-17D	ECE	Tue	CR-07-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1178	Mr. Habeel Ahmad	Electrical Network Analysis	2K25-BEE-17D	ECE	Tue	CR-07-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1179	Dr. Hina Munir Dutt	Differential Equations	2K25-BEE-17D	H&S	Tue	CR-09-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1180	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Tue	CR-19-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1181	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Tue	CR-19-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1182	Mr. Habeel Ahmad	Electrical Network Analysis	2K25-BEE-17D	ECE	Wed	CR-15-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1183	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17D	H&S	Wed	CR-15-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1184	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17D	H&S	Wed	CR-15-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1185	Dr. Hina Munir Dutt	Differential Equations	2K25-BEE-17D	H&S	Wed	CR-15-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1186	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K25-BEE-17D	H&S	Wed	CR-15-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1187	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K25-BEE-17D	H&S	Wed	CR-15-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1188	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16A	H&S	Fri	CR-04-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1189	Dr. Aimal Tariq Rextin	Object Oriented Programming	2K25-BESE-16A	FoC	Fri	CR-09-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1190	Dr. Aimal Tariq Rextin	Object Oriented Programming	2K25-BESE-16A	FoC	Fri	CR-09-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1191	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BESE-16A	H&S	Mon	CR-09-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1192	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2K25-BESE-16A	FoC	Mon	CR-09-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1193	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2K25-BESE-16A	FoC	Mon	CR-09-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1194	Dr. Aimal Tariq Rextin	Object Oriented Programming	2K25-BESE-16A	FoC	Mon	Computing Lab-03	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1195	Dr. Aimal Tariq Rextin	Object Oriented Programming	2K25-BESE-16A	FoC	Mon	Computing Lab-03	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1196	Dr. Aimal Tariq Rextin	Object Oriented Programming	2K25-BESE-16A	FoC	Mon	Computing Lab-03	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1197	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2K25-BESE-16A	FoC	Thu	CR-09-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
1198	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2K25-BESE-16A	FoC	Thu	Digital Systems Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1199	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2K25-BESE-16A	FoC	Thu	Digital Systems Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1200	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2K25-BESE-16A	FoC	Thu	Digital Systems Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1201	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Thu	CR-09-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1202	Dr. Aimal Tariq Rextin	Object Oriented Programming	2K25-BESE-16A	FoC	Thu	CR-09-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1203	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BESE-16A	H&S	Tue	CR-09-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1204	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Tue	CR-09-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1205	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Tue	CR-09-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1206	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16A	H&S	Wed	CR-01-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1207	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16A	H&S	Wed	CR-01-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1208	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BESE-16A	H&S	Wed	CR-09-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1209	Mr. Saif Ullah	Understanding of Quran II	2K25-BESE-16A	H&S	Wed	CR-09-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1210	Mr. Saif Ullah	Understanding of Quran II	2K25-BESE-16A	H&S	Wed	CR-09-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1211	Mr. Saif Ullah	Understanding of Quran II	2K25-BESE-16A	H&S	Wed	CR-09-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1212	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16B	H&S	Fri	CR-04-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1213	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Fri	CR-10-UG Block	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1214	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Fri	CR-10-UG Block	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1215	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Fri	CR-10-UG Block	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1216	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Fri	CR-10-UG Block	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1217	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Fri	CR-10-UG Block	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1218	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Fri	CR-10-UG Block	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1219	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BESE-16B	H&S	Mon	CR-10-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1220	Dr. Muhammad Daud Abdullah Asif	Object Oriented Programming	2K25-BESE-16B	FoC	Mon	Computing Lab-03	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1221	Dr. Muhammad Daud Abdullah Asif	Object Oriented Programming	2K25-BESE-16B	FoC	Mon	Computing Lab-03	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1222	Dr. Muhammad Daud Abdullah Asif	Object Oriented Programming	2K25-BESE-16B	FoC	Mon	Computing Lab-03	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1223	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	FoC	Mon	CR-10-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1224	Dr. Muhammad Daud Abdullah Asif	Object Oriented Programming	2K25-BESE-16B	FoC	Mon	CR-10-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1225	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16B	H&S	Thu	Lecture Hall-PG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1226	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16B	H&S	Thu	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1227	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	FoC	Thu	Digital Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1228	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	FoC	Thu	Digital Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1229	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	FoC	Thu	Digital Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1230	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BESE-16B	H&S	Tue	CR-10-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1231	Ms. Sadia Arshad	Functional English	2K25-BESE-16B	H&S	Tue	CR-10-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1232	Ms. Sadia Arshad	Functional English	2K25-BESE-16B	H&S	Tue	CR-10-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1233	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	FoC	Tue	CR-10-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1234	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	FoC	Tue	CR-10-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1235	Ms. Sadia Arshad	Functional English	2K25-BESE-16B	H&S	Wed	CR-10-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1236	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BESE-16B	H&S	Wed	CR-10-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1237	Dr. Muhammad Daud Abdullah Asif	Object Oriented Programming	2K25-BESE-16B	FoC	Wed	CR-10-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1238	Dr. Muhammad Daud Abdullah Asif	Object Oriented Programming	2K25-BESE-16B	FoC	Wed	CR-10-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1239	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAI-2A	FoC	Fri	CR-01-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1240	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSAI-2A	ECE	Fri	Digital Systems Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1241	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSAI-2A	ECE	Fri	Digital Systems Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1242	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSAI-2A	ECE	Fri	Digital Systems Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1243	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSAI-2A	H&S	Fri	CR-05-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1244	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSAI-2A	H&S	Fri	CR-05-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1245	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSAI-2A	H&S	Fri	CR-05-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1246	Dr. Atifa Kanwal	Multivariable Calculus	2K25-BSAI-2A	H&S	Mon	CR-01-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1247	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAI-2A	FoC	Mon	CR-01-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1248	Mr. Saeed Afzal	Linear Algebra	2K25-BSAI-2A	H&S	Mon	CR-01-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1249	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSAI-2A	ECE	Mon	CR-01-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1250	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSAI-2A	ECE	Mon	CR-01-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1251	Mr. Saeed Afzal	Linear Algebra	2K25-BSAI-2A	H&S	Thu	CR-16-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1252	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAI-2A	FoC	Thu	Computing Lab-01	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1253	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAI-2A	FoC	Thu	Computing Lab-01	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1254	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAI-2A	FoC	Thu	Computing Lab-01	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1255	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAI-2A	FoC	Tue	CR-01-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1256	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAI-2A	FoC	Tue	CR-01-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1257	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAI-2A	FoC	Tue	CR-01-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1258	Mr. Saeed Afzal	Linear Algebra	2K25-BSAI-2A	H&S	Wed	Lecture Hall-PG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1259	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAI-2A	FoC	Wed	Lecture Hall-PG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1260	Dr. Atifa Kanwal	Multivariable Calculus	2K25-BSAI-2A	H&S	Wed	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1261	Dr. Atifa Kanwal	Multivariable Calculus	2K25-BSAI-2A	H&S	Wed	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1262	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAI-2A	FoC	Wed	Computing Lab-01	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1263	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAI-2A	FoC	Wed	Computing Lab-01	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1264	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAI-2A	FoC	Wed	Computing Lab-01	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1265	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Fri	CR-02-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1266	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15A	ECE	Fri	CR-02-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1267	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Fri	Computing Lab-05	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1268	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Fri	Computing Lab-05	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1269	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Fri	Computing Lab-05	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1270	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15A	H&S	Mon	CR-02-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1271	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Mon	CR-02-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1272	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Mon	CR-02-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1273	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15A	ECE	Mon	Digital Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1274	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15A	ECE	Mon	Digital Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1275	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15A	ECE	Mon	Digital Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1276	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Thu	CR-03-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1277	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Thu	CR-03-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1278	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15A	H&S	Thu	CR-03-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1279	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15A	H&S	Thu	CR-03-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1280	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15A	ECE	Thu	CR-05-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1281	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15A	H&S	Tue	CR-03-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1282	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Tue	Computing Lab-05	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1283	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Tue	Computing Lab-05	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1284	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Tue	Computing Lab-05	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1285	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1286	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1287	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Wed	CR-02-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1288	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1289	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1290	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1291	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Fri	Computing Lab-05	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
1292	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Fri	Computing Lab-05	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1293	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Fri	Computing Lab-05	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1294	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15B	H&S	Fri	CR-05-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1295	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15B	FoC	Fri	CR-02-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1296	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15B	FoC	Fri	CR-02-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1297	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Mon	CR-01-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1298	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Mon	Digital Systems Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1299	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Mon	Digital Systems Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1300	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Mon	Digital Systems Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1301	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15B	H&S	Mon	CR-02-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1302	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Thu	CR-02-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1303	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15B	FoC	Thu	CR-02-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1304	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15B	H&S	Thu	CR-02-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1305	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15B	H&S	Thu	CR-02-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
1306	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Tue	CR-02-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1307	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Tue	CR-02-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1308	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Tue	CR-02-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1309	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15B	H&S	Tue	CR-02-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1310	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15B	FoC	Tue	Computing Lab-05	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1311	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15B	FoC	Tue	Computing Lab-05	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1312	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15B	FoC	Tue	Computing Lab-05	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1313	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15B	H&S	Wed	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1314	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Wed	CR-04-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1315	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Wed	CR-11-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1316	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Wed	CR-04-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1317	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Wed	CR-11-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1318	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Wed	CR-04-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1319	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Wed	CR-11-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1320	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Fri	CR-03-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1321	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Fri	CR-03-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1322	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Fri	CR-03-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1323	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15C	H&S	Fri	CR-03-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1324	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15C	H&S	Fri	CR-03-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1325	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15C	H&S	Mon	CR-04-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1326	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15C	H&S	Mon	CR-03-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1327	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15C	H&S	Mon	CR-03-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1328	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15C	H&S	Mon	CR-03-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1329	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Thu	Computing Lab-05	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
1330	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Thu	Computing Lab-05	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1331	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Thu	Computing Lab-05	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1332	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Thu	CR-02-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1333	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15C	H&S	Thu	CR-03-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1334	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15C	H&S	Tue	CR-03-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1335	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Tue	CR-03-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1336	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Tue	CR-03-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1337	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Tue	Digital Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1338	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Tue	Digital Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1339	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Tue	Digital Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1340	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Wed	CR-03-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1341	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Wed	CR-03-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1342	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15C	H&S	Wed	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1343	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Wed	Computing Lab-05	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1344	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Wed	Computing Lab-05	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1345	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Wed	Computing Lab-05	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1346	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15D	ECE	Fri	CR-06-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1347	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15D	ECE	Fri	CR-06-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1348	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15D	H&S	Fri	CR-06-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1349	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15D	H&S	Fri	CR-06-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1350	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15D	H&S	Mon	CR-03-UG Block	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
1351	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15D	H&S	Mon	CR-03-UG Block	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1352	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15D	H&S	Mon	CR-03-UG Block	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1353	Ms. Ayesha Kanwal	Object Oriented Programming	2K25-BSCS-15D	FoC	Mon	CR-03-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1354	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Mon	Computing Lab-05	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1355	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Mon	Computing Lab-05	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1356	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Mon	Computing Lab-05	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1357	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15D	H&S	Thu	CR-02-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1358	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15D	H&S	Thu	CR-02-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1359	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Thu	CR-10-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1360	Ms. Ayesha Kanwal	Object Oriented Programming	2K25-BSCS-15D	FoC	Thu	Computing Lab-05	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1361	Ms. Ayesha Kanwal	Object Oriented Programming	2K25-BSCS-15D	FoC	Thu	Computing Lab-05	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1362	Ms. Ayesha Kanwal	Object Oriented Programming	2K25-BSCS-15D	FoC	Thu	Computing Lab-05	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1363	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15D	ECE	Tue	Digital Systems Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1364	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15D	ECE	Tue	Digital Systems Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1365	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15D	ECE	Tue	Digital Systems Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	\N
1366	Ms. Ayesha Kanwal	Object Oriented Programming	2K25-BSCS-15D	FoC	Tue	CR-03-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1367	Ms. Ayesha Kanwal	Object Oriented Programming	2K25-BSCS-15D	FoC	Tue	CR-03-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
1368	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15D	H&S	Wed	CR-03-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1369	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15D	H&S	Wed	CR-03-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1370	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Wed	CR-03-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1371	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Wed	CR-03-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1372	Dr. Atifa Kanwal	Calculus & Analytical Geometry	2K25-BSCS-15E	H&S	Fri	CR-11-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1373	Dr. Atifa Kanwal	Calculus & Analytical Geometry	2K25-BSCS-15E	H&S	Fri	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1374	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Fri	CR-04-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1375	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Fri	CR-04-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1376	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Fri	CR-04-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1377	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Fri	CR-04-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1378	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Fri	CR-04-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1379	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Fri	CR-04-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1380	Dr. Hirra Anwar	Database Systems	2K25-BSCS-15E	FoC	Mon	Computing Lab-05	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
1381	Dr. Hirra Anwar	Database Systems	2K25-BSCS-15E	FoC	Mon	Computing Lab-05	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1382	Dr. Hirra Anwar	Database Systems	2K25-BSCS-15E	FoC	Mon	Computing Lab-05	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1383	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSCS-15E	H&S	Mon	CR-02-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1384	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15E	H&S	Mon	CR-04-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1385	Dr. Sarosh Tahir	Object Oriented Programming	2K25-BSCS-15E	FoC	Mon	CR-04-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1386	Dr. Rai Sajjad Saif	Linear Algebra	2K25-BSCS-15E	H&S	Mon	CR-04-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1387	Dr. Rai Sajjad Saif	Linear Algebra	2K25-BSCS-15E	H&S	Mon	CR-04-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
1388	Dr. Atifa Kanwal	Calculus & Analytical Geometry	2K25-BSCS-15E	H&S	Thu	CR-06-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1389	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15E	H&S	Thu	CR-04-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1390	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSCS-15E	H&S	Thu	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1391	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15E	H&S	Thu	CR-04-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1392	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSCS-15E	H&S	Thu	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1393	Dr. Hirra Anwar	Database Systems	2K25-BSCS-15E	FoC	Thu	CR-04-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1394	Dr. Hirra Anwar	Database Systems	2K25-BSCS-15E	FoC	Thu	CR-04-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1395	Dr. Rai Sajjad Saif	Linear Algebra	2K25-BSCS-15E	H&S	Thu	CR-04-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
1396	Dr. Sarosh Tahir	Object Oriented Programming	2K25-BSCS-15E	FoC	Tue	CR-04-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1397	Dr. Sarosh Tahir	Object Oriented Programming	2K25-BSCS-15E	FoC	Tue	CR-04-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1398	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15E	ECE	Tue	CR-04-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1399	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15E	ECE	Tue	CR-04-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1400	Dr. Sarosh Tahir	Object Oriented Programming	2K25-BSCS-15E	FoC	Wed	Computing Lab-05	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
1401	Dr. Sarosh Tahir	Object Oriented Programming	2K25-BSCS-15E	FoC	Wed	Computing Lab-05	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1402	Dr. Sarosh Tahir	Object Oriented Programming	2K25-BSCS-15E	FoC	Wed	Computing Lab-05	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1403	Dr. Hirra Anwar	Database Systems	2K25-BSCS-15E	FoC	Wed	CR-09-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1404	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15E	ECE	Wed	Digital Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1405	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15E	ECE	Wed	Digital Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1406	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15E	ECE	Wed	Digital Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1407	Dr. Atifa Kanwal	Calculus & Analytical Geometry	2K25-BSDS-3A	H&S	Fri	CR-11-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1408	Dr. Bilal Ahmed	Linear Algebra	2K25-BSDS-3A	H&S	Fri	CR-04-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1409	Dr. Atifa Kanwal	Calculus & Analytical Geometry	2K25-BSDS-3A	H&S	Fri	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1410	Dr. Bilal Ahmed	Linear Algebra	2K25-BSDS-3A	H&S	Fri	CR-04-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1411	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSDS-3A	ECE	Fri	Digital Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1412	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSDS-3A	ECE	Fri	Digital Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1413	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSDS-3A	ECE	Fri	Digital Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1414	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSDS-3A	FoC	Mon	Computing Lab-02	09:00 AM	10:00 AM	Lab	\N	\N			540	\N
1415	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSDS-3A	FoC	Mon	Computing Lab-02	10:00 AM	11:00 AM	Lab	\N	\N			600	\N
1416	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSDS-3A	FoC	Mon	Computing Lab-02	11:00 AM	12:00 PM	Lab	\N	\N			660	\N
1417	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSDS-3A	H&S	Mon	CR-02-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1418	Dr. Atifa Kanwal	Multivariable Calculus	2K25-BSDS-3A	H&S	Mon	CR-14-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1419	Dr. Fahad Ahmed Satti	Database Systems	2K25-BSDS-3A	FoC	Mon	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1420	Dr. Fahad Ahmed Satti	Database Systems	2K25-BSDS-3A	FoC	Mon	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1421	Dr. Fahad Ahmed Satti	Database Systems	2K25-BSDS-3A	FoC	Mon	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1422	Dr. Atifa Kanwal	Calculus & Analytical Geometry	2K25-BSDS-3A	H&S	Thu	CR-06-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1423	Dr. Atifa Kanwal	Multivariable Calculus	2K25-BSDS-3A	H&S	Thu	CR-01-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1424	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSDS-3A	H&S	Thu	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1425	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSDS-3A	H&S	Thu	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1426	Dr. Atifa Kanwal	Multivariable Calculus	2K25-BSDS-3A	H&S	Thu	CR-01-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1427	Dr. Fahad Ahmed Satti	Database Systems	2K25-BSDS-3A	FoC	Thu	CR-01-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	\N
1428	Dr. Fahad Ahmed Satti	Database Systems	2K25-BSDS-3A	FoC	Thu	CR-01-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	\N
1429	Dr. Bilal Ahmed	Linear Algebra	2K25-BSDS-3A	H&S	Thu	CR-01-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	\N
1430	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSDS-3A	FoC	Tue	CR-14-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	\N
1431	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSDS-3A	FoC	Tue	CR-14-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1432	Dr. Fahad Ahmed Satti	Database Systems	2K25-BSDS-3A	FoC	Tue	CR-01-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1433	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSDS-3A	FoC	Wed	CR-14-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	\N
1434	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSDS-3A	ECE	Wed	CR-01-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	\N
1435	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSDS-3A	ECE	Wed	CR-01-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	\N
1436	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSDS-3A	H&S	Wed	CR-01-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	\N
1437	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSDS-3A	H&S	Wed	CR-01-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	\N
1438	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSDS-3A	H&S	Wed	CR-01-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	\N
1439	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Wed	CR-11-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-01-28	Elective		660	\N
1440	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Wed	CR-11-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-01-28	Elective		660	\N
1441	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Wed	CR-11-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-01-28	Elective		660	\N
1442	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Wed	CR-11-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-01-28	Elective		660	\N
1443	Dr. Tahira Anwar Lashari	Principles of Sociology	2K22-BSCS-12C	FoC	Mon	CR-09-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-02-02			840	\N
1444	Dr. Tahira Anwar Lashari	Principles of Sociology	2K22-BSCS-12C	FoC	Mon	CR-09-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-02			900	\N
1445	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Mon	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-01-26			660	\N
1446	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Thu	Control System Lab	03:00 PM	04:00 PM	Lec	Makeup	2026-01-22			900	\N
1447	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Tue	DSP & Comm Lab	11:00 AM	12:00 PM	Lec	Makeup	2026-01-20			660	\N
1448	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Mon	Lecture Hall-PG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-01-26			960	\N
1449	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Thu	Control System Lab	03:00 PM	04:00 PM	Lec	Makeup	2026-01-22			900	\N
1450	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Thu	CR-09-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-01-29			720	\N
1451	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Thu	CR-09-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-01-22			840	\N
1452	Dr. Fahad Ahmed Satti	Parallel & Distributed Computing	2K23-BSDS-1A	FoC	Tue	CR-28-Acad Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-03			960	\N
1453	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Fri	CR-02-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-01-30			540	\N
1454	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Fri	CR-02-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-01-30			600	\N
1455	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Thu	CR-05-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-01-29			600	\N
1456	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Wed	CR-08-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-01-28			900	\N
1457	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Wed	CR-08-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-01-28			960	\N
1458	Dr. Mehwish Fatima	Programming for AI	2K24-BSAI-1A	FoC	Tue	Computing Lab-04	11:00 AM	12:00 PM	Lec	Makeup	2026-01-20			660	\N
1459	Dr. Mehwish Fatima	Programming for AI	2K24-BSAI-1A	FoC	Tue	Computing Lab-04	03:00 PM	04:00 PM	Lec	Makeup	2026-01-20			900	\N
1460	Dr. Imran Malik	Applied Physics	2K24-BSCS-14A	H&S	Mon	CR-04-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-02			540	\N
1461	Dr. Imran Malik	Applied Physics	2K24-BSCS-14B	H&S	Mon	CR-21-SMRIMMS	03:00 PM	04:00 PM	Lec	Makeup	2026-02-02			900	\N
1462	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Tue	CR- 22 RIMMS	09:00 AM	10:00 AM	Lec	Makeup	2026-02-03			540	\N
1463	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Tue	CR- 22 RIMMS	09:00 AM	10:00 AM	Lec	Makeup	2026-02-10			540	\N
1464	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Tue	CR- 22 RIMMS	09:00 AM	10:00 AM	Lec	Makeup	2026-02-17			540	\N
1465	Dr. Sohail Iqbal	Theory of Automata	2K24-BSCS-14D	FoC	Thu	CR-06-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-01-29			660	\N
1466	Dr. Sohail Iqbal	Theory of Automata	2K24-BSCS-14D	FoC	Thu	CR-06-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-19			720	\N
1467	Dr. Samia Tahir	Expository Writing	2K24-BSCS-14D	H&S	Tue	CR-06-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-01-27			840	\N
1468	Dr. Nazia Pervaiz	Machine Learning	2K24-BSDS-2A	FoC	Fri	CR-12-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-01-30			540	\N
1469	Dr. Nazia Pervaiz	Machine Learning	2K24-BSDS-2A	FoC	Thu	CR-12-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-01-29			840	\N
1470	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Tue	Basic Electronics Lab	10:00 AM	11:00 AM	Lec	Makeup	2026-01-27			600	\N
1471	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17B	H&S	Fri	Lecture Hall-PG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-01-30			600	\N
1472	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17B	H&S	Fri	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-01-30			660	\N
1473	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Tue	Basic Electronics Lab	11:00 AM	12:00 PM	Lec	Makeup	2026-01-27			660	\N
1474	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	Basic Electronics Lab	02:00 PM	03:00 PM	Lab	Missed	2026-01-26			840	\N
1475	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	Basic Electronics Lab	03:00 PM	04:00 PM	Lab	Missed	2026-01-26			900	\N
1476	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	Basic Electronics Lab	04:00 PM	05:00 PM	Lab	Missed	2026-01-26			960	\N
1477	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	Basic Electronics Lab	03:00 PM	04:00 PM	Lab	Missed	2026-01-26			900	\N
1478	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	Basic Electronics Lab	04:00 PM	05:00 PM	Lab	Missed	2026-01-26			960	\N
1479	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	10:00 AM	11:00 AM	Lab	Makeup	2026-01-30			600	\N
1480	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	11:00 AM	12:00 PM	Lab	Makeup	2026-01-30			660	\N
1481	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	12:00 AM	01:00 AM	Lab	Makeup	2026-01-30			0	\N
1482	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	01:00 AM	02:00 AM	Lab	Makeup	2026-01-30			60	\N
1483	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	02:00 AM	03:00 AM	Lab	Makeup	2026-01-30			120	\N
1484	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	03:00 AM	04:00 AM	Lab	Makeup	2026-01-30			180	\N
1485	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	04:00 AM	05:00 AM	Lab	Makeup	2026-01-30			240	\N
1486	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	05:00 AM	06:00 AM	Lab	Makeup	2026-01-30			300	\N
1487	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	06:00 AM	07:00 AM	Lab	Makeup	2026-01-30			360	\N
1488	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	07:00 AM	08:00 AM	Lab	Makeup	2026-01-30			420	\N
1489	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	08:00 AM	09:00 AM	Lab	Makeup	2026-01-30			480	\N
1490	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	09:00 AM	10:00 AM	Lab	Makeup	2026-01-30			540	\N
1491	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	10:00 AM	11:00 AM	Lab	Makeup	2026-01-30			600	\N
1492	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	11:00 AM	12:00 PM	Lab	Makeup	2026-01-30			660	\N
1493	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	Basic Electronics Lab	12:00 PM	01:00 PM	Lab	Makeup	2026-01-30			720	\N
1494	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2k25-BEE-17C	H&S	Fri	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-01-30			660	\N
1495	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2k25-BEE-17C	H&S	Fri	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-01-30			720	\N
1496	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	ECE	Wed	Computing Lab-07	02:00 PM	03:00 PM	Lec	Makeup	2026-01-21			840	\N
1497	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Thu	CR-10-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-01-29			960	\N
1498	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Tue	CR-09-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-03			600	\N
1499	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Tue	CR-09-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-02-03			660	\N
1500	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16A	H&S	Tue	CR-09-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-01-20			660	\N
1501	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	ECE	Thu	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-01-22			720	\N
1502	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Tue	CR-07-UG Block	04:00 PM	05:00 PM	Lab	Makeup	2026-02-03			960	\N
1503	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	ECE	Wed	CR-08-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-04			600	\N
1504	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	ECE	Wed	CR-08-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-02-04			660	\N
1505	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15A	H&S	Tue	CR-02-UG Block	12:00 PM	01:00 PM	Lab	Makeup	2026-01-27			720	\N
1506	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15A	ECE	Tue	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-03			900	\N
1507	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15A	ECE	Tue	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-10			900	\N
1508	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Thu	CR-02-UG Block	04:00 PM	05:00 PM	Lab	Makeup	2026-01-29			960	\N
1509	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Mon	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-02-02			840	\N
1510	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Tue	Lecture Hall-PG Block	09:00 AM	10:00 AM	Lab	Makeup	2026-02-03			540	\N
1511	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Tue	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-02-03	Elective		900	\N
1512	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Tue	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-01-20	Elective		900	\N
1513	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Tue	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Missed	2026-02-03	Elective		960	\N
1514	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Tue	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-02-03	Elective		900	\N
1515	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Tue	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-01-20	Elective		900	\N
1516	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Tue	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Missed	2026-02-03	Elective		960	\N
1517	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Tue	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-02-03	Elective		900	\N
1518	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Tue	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-01-20	Elective		900	\N
1519	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Tue	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Missed	2026-02-03	Elective		960	\N
1520	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Tue	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-02-03	Elective		900	\N
1521	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Tue	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-01-20	Elective		900	\N
1522	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Tue	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Missed	2026-02-03	Elective		960	\N
1523	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Tue	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-20			660	\N
1524	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Tue	CR-19-IAEC	11:00 AM	12:00 PM	Lec	Missed	2026-02-03			660	\N
1525	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Tue	CR-20-IAEC	02:00 PM	03:00 PM	Lec	Missed	2026-02-03			840	\N
1526	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Tue	CR-19-IAEC	10:00 AM	11:00 AM	Lec	Missed	2026-02-03			600	\N
1527	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Fri	CR-02-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-01-30			720	\N
1528	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Tue	CR-18-IAEC	02:00 PM	03:00 PM	Lec	Missed	2026-02-03			840	\N
1529	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Tue	CR-18-IAEC	03:00 PM	04:00 PM	Lec	Missed	2026-02-03			900	\N
1530	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Wed	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-28			660	\N
1531	Dr. Hashir Moheed Kiyani	Machine Learning	2K23-BESE-14A	FoC	Tue	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Missed	2026-01-20			960	\N
1532	Mr. Hamza Saleem	Human Computer Interaction	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	09:00 AM	10:00 AM	Lec	Missed	2026-02-03			540	\N
1533	Mr. Hamza Saleem	Human Computer Interaction	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	10:00 AM	11:00 AM	Lec	Missed	2026-02-03			600	\N
1534	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Tue	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-27			660	\N
1535	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Tue	CR-02-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-01-27			720	\N
1536	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16C	H&S	Wed	CR-02-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-01-21			840	\N
1537	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16D	H&S	Wed	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-01-21			900	\N
1538	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16D	H&S	Wed	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Missed	2026-01-21			960	\N
1539	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Tue	CR-02-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-01-27			840	\N
1540	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Tue	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-01-27			900	\N
1541	Dr. Aimal Tariq Rextin	Design & Analysis of Algorithm	2K24-BESE-15B	FoC	Tue	CR-02-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-01-27			840	\N
1542	Dr. Aimal Tariq Rextin	Design & Analysis of Algorithm	2K24-BESE-15B	FoC	Tue	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-01-27			900	\N
1543	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Wed	CR-02-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-01-28			840	\N
1544	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Wed	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-01-28			900	\N
1545	Dr. Mehwish Fatima	Programming for AI	2K24-BSAI-1A	FoC	Mon	CR-02-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-01-19			840	\N
1546	Dr. Mehwish Fatima	Programming for AI	2K24-BSAI-1A	FoC	Mon	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-01-19			900	\N
1547	Dr. Samia Tahir	Expository Writing	2K24-BSAI-1A	H&S	Thu	CR-02-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-01-29			540	\N
1548	Dr. Naima Iltaaf	Web Technologies	2K24-BSAI-1A	FoC	Thu	CR-02-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-01-22			600	\N
1549	Dr. Naima Iltaaf	Web Technologies	2K24-BSAI-1A	FoC	Thu	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-22			660	\N
1550	Dr. Samia Tahir	Expository Writing	2K24-BSAI-1A	H&S	Tue	CR-02-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-01-27			540	\N
1551	Dr. Seemab Latif	Machine Learning	2K24-BSAI-1A	FoC	Tue	CR-02-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-01-27			840	\N
1552	Dr. Seemab Latif	Machine Learning	2K24-BSAI-1A	FoC	Tue	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-01-27			900	\N
1553	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Mon	CR-02-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-02-02			540	\N
1554	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Mon	CR-02-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-02-02			600	\N
1555	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Wed	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Missed	2026-01-28			960	\N
1556	Dr. Samia Tahir	Expository Writing	2K24-BSCS-14D	H&S	Fri	CR-02-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-01-30			600	\N
1557	Dr. Naima Iltaaf	Web Technologies	2K24-BSCS-14D	FoC	Mon	CR-02-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-01-19			840	\N
1558	Dr. Naima Iltaaf	Web Technologies	2K24-BSCS-14D	FoC	Mon	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-01-19			900	\N
1559	Dr. Samia Tahir	Expository Writing	2K24-BSCS-14D	H&S	Thu	CR-02-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-01-29			720	\N
1560	Dr. Samia Tahir	Expository Writing	2K24-BSDS-2A	H&S	Fri	CR-02-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-01-30			540	\N
1561	Dr. Rabia Irfan	Introduction to Data Science	2K24-BSDS-2A	FoC	Mon	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-02-02			900	\N
1562	Dr. Rabia Irfan	Introduction to Data Science	2K24-BSDS-2A	FoC	Mon	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Missed	2026-02-02			960	\N
1563	Dr. Samia Tahir	Expository Writing	2K24-BSDS-2A	H&S	Thu	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-29			660	\N
1564	Dr. Ahmed Naeem	Logic and Sequential Circuit Design	2K25-BCE-1A	ECE	Tue	CR-13-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-02-03			540	\N
1565	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Wed	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Missed	2026-01-28			960	\N
1566	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	CR-02-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-01-30			600	\N
1567	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Fri	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-30			660	\N
1568	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	ECE	Mon	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-19			660	\N
1569	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	CR-02-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-01-26			840	\N
1570	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-01-26			900	\N
1571	Mr. Ammar Ahmed	Islamic Studies	2k25-BEE-17C	H&S	Thu	CR-02-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-01-29			720	\N
1572	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2K25-BESE-16A	FoC	Mon	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-19			660	\N
1573	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2K25-BESE-16A	FoC	Mon	CR-02-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-01-19			720	\N
1574	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16A	H&S	Wed	CR-02-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-01-21			600	\N
1575	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Fri	CR-02-UG Block	10:00 AM	11:00 AM	Lab	Missed	2026-01-30			600	\N
1576	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	ECE	Mon	CR-02-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-01-26			840	\N
1577	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	ECE	Mon	CR-02-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-02-02			840	\N
1578	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	ECE	Tue	CR-02-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-01-27			840	\N
1579	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	ECE	Tue	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-01-27			900	\N
1580	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Fri	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-30			660	\N
1581	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Mon	CR-02-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-01-26			600	\N
1582	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Mon	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-26			660	\N
1583	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15A	H&S	Thu	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-22			660	\N
1584	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15A	H&S	Thu	CR-02-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-01-22			720	\N
1585	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-01-21			600	\N
1586	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Wed	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-28			660	\N
1587	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	02:00 PM	03:00 PM	Lab	Missed	2026-01-28			840	\N
1588	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Mon	CR-02-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-01-26			540	\N
1589	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Tue	CR-02-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-01-27			540	\N
1590	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Tue	CR-02-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-01-27			600	\N
1591	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Wed	CR-02-UG Block	02:00 PM	03:00 PM	Lab	Missed	2026-01-28			840	\N
1592	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Tue	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-27			660	\N
1593	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Wed	CR-02-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-01-28			540	\N
1594	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Wed	CR-02-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-01-28			600	\N
1595	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15D	H&S	Thu	CR-02-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-01-29			540	\N
1596	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15D	H&S	Thu	CR-02-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-01-22			600	\N
1597	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15D	H&S	Wed	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-21			660	\N
1598	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15D	H&S	Wed	CR-02-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-01-21			720	\N
1599	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Fri	CR-02-UG Block	02:00 PM	03:00 PM	Lab	Missed	2026-01-30			840	\N
1600	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15E	H&S	Thu	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-29			660	\N
1601	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15E	H&S	Thu	CR-02-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-01-29			720	\N
1602	Dr. Rai Sajjad Saif	Linear Algebra	2K25-BSCS-15E	H&S	Thu	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Missed	2026-01-22			960	\N
1603	Dr. Bilal Ahmed	Linear Algebra	2K25-BSDS-3A	H&S	Fri	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-01-23			660	\N
1604	Dr. Bilal Ahmed	Linear Algebra	2K25-BSDS-3A	H&S	Fri	CR-02-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-01-23			720	\N
1605	Dr. Bilal Ahmed	Linear Algebra	2K25-BSDS-3A	H&S	Thu	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Missed	2026-01-22			960	\N
1606	Dr. Imran Malik	Applied Physics	2K24-BSCS-14A	ECE	Mon	CR-04-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-02			540	\N
1607	Dr. Imran Malik	Applied Physics	2K24-BSCS-14B	ECE	Mon	CR-21-SMRIMMS	02:00 PM	03:00 PM	Lec	Makeup	2026-02-02			840	\N
1608	Dr. Imran Malik	Applied Physics	2k24-BSDS-2A	ECE	Fri	CR-12-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-06			720	\N
1609	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Tue	Computing Lab-01	09:00 AM	10:00 AM	Lec	Makeup	2026-02-03			540	\N
1610	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Tue	Basic Electronics Lab	12:00 PM	01:00 PM	Lec	Makeup	2026-02-03			720	\N
1611	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Tue	Basic Electronics Lab	02:00 PM	03:00 PM	Lec	Makeup	2026-02-03			840	\N
1612	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Wed	CR-24-Acad Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-04			720	\N
1613	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Wed	CR-24-Acad Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-11			720	\N
1614	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Wed	CR-24-Acad Block	11:00 AM	12:00 PM	Lec	Makeup	2026-02-04			660	\N
1615	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Wed	CR-24-Acad Block	11:00 AM	12:00 PM	Lec	Makeup	2026-02-11			660	\N
1616	Mr. Hamza Saleem	Human Computer Interaction	2K23-BESE-14B	FoC	Fri	CR-24-Acad Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-06			540	\N
1617	Mr. Hamza Saleem	Human Computer Interaction	2K23-BESE-14B	FoC	Fri	CR-24-Acad Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-06			600	\N
1618	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13C	FoC	Wed	SMRIMMS Seminar Hall	09:00 AM	10:00 AM	Lec	Makeup	2026-02-04			540	\N
1619	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13C	FoC	Wed	SMRIMMS Seminar Hall	10:00 AM	11:00 AM	Lec	Makeup	2026-02-04			600	\N
1620	Dr. Mehwish Awan	Deep Learning	2K23-BSCS-13C	FoC	Fri	CR-26-Acad Block	11:00 AM	12:00 PM	Lec	Makeup	2026-02-06			660	\N
1621	Dr. Mehwish Awan	Deep Learning	2K23-BSCS-13C	FoC	Fri	CR-26-Acad Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-06			720	\N
1622	Ms. Sahar Arshad	Mobile Application Development-I	2K23-BSDS-1A	FoC	Wed	Computing Lab-07	11:00 AM	12:00 PM	Lec	Makeup	2026-02-04			660	\N
1623	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Fri	CR-05-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-13			600	\N
1624	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Fri	CR-05-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-20			600	\N
1625	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Fri	CR-05-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-27			600	\N
1626	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Thu	CR-05-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-12			540	\N
1627	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Thu	CR-05-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-12			600	\N
1628	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Thu	CR-05-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-19			540	\N
1629	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Thu	CR-05-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-19			600	\N
1630	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Fri	CR-05-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-13			540	\N
1631	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Fri	CR-05-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-20			540	\N
1632	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Fri	CR-05-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-27			540	\N
1633	Dr. Naima Iltaaf	Web Technologies	2K24-BSAi-1A	FoC	Fri	Computing Lab-08	09:00 AM	10:00 AM	Lec	Makeup	2026-02-06			540	\N
1634	Dr. Naima Iltaaf	Web Technologies	2K24-BSAi-1A	FoC	Fri	Computing Lab-08	10:00 AM	11:00 AM	Lec	Makeup	2026-02-06			600	\N
1635	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14A	FoC	Thu	CR-04-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-12			540	\N
1636	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Mon	CR-05-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-09			900	\N
1637	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Mon	CR-05-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-09			960	\N
1638	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Fri	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-13			900	\N
1639	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Fri	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-13			960	\N
1640	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Fri	CR-02-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-20			540	\N
1641	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Fri	CR-02-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-20			600	\N
1642	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Wed	CR-22-SMRIMMS	09:00 AM	10:00 AM	Lec	Makeup	2026-02-04			540	\N
1643	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Wed	CR-22-SMRIMMS	09:00 AM	10:00 AM	Lec	Makeup	2026-02-11			540	\N
1644	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Wed	CR-22-SMRIMMS	09:00 AM	10:00 AM	Lec	Makeup	2026-02-18			540	\N
1645	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K25-BCE-1A	H&S	Tue	CR-13-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-10			900	\N
1646	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K25-BCE-1A	H&S	Tue	CR-13-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-10			960	\N
1647	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Mon	Lecture Hall-PG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-09			900	\N
1648	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Mon	Lecture Hall-PG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-09			900	\N
1649	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Mon	Lecture Hall-PG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-09			960	\N
1650	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Thu	Computing Lab-11	09:00 AM	10:00 AM	Lec	Makeup	2026-02-12			540	\N
1651	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Thu	Computing Lab-11	10:00 AM	11:00 AM	Lec	Makeup	2026-02-12			600	\N
1652	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Mon	CR-04-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-09			600	\N
1653	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14C	ECE	Mon	CR-11-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-02-09			840	\N
1654	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14C	ECE	Mon	CR-11-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-09			900	\N
1655	Ms. Sahar Arshad	Mobile Application Development-I	2K23-BSDS-1A	FoC	Mon	CR-05-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-09			540	\N
1656	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAi-2A	FoC	Wed	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-02-11			840	\N
1657	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Thu	CR-06-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-12	Elective		900	\N
1658	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Thu	CR-06-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-12	Elective		960	\N
1659	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Thu	CR-06-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-26	Elective		900	\N
1660	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Thu	CR-06-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-26	Elective		960	\N
1661	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Thu	CR-06-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-03-05	Elective		900	\N
1662	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Thu	CR-06-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-03-05	Elective		960	\N
1663	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-02-12	Elective		840	\N
1664	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-02-12	Elective		840	\N
1665	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-02-19	Elective		840	\N
1666	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-02-19	Elective		840	\N
1667	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-02-26	Elective		840	\N
1668	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-02-26	Elective		840	\N
1669	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-03-05	Elective		840	\N
1670	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-03-05	Elective		840	\N
1671	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-03-19	Elective		840	\N
1672	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-03-19	Elective		840	\N
1673	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-03-26	Elective		840	\N
1674	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-03-26	Elective		840	\N
1675	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-04-02	Elective		840	\N
1676	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-04-02	Elective		840	\N
1677	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-04-09	Elective		840	\N
1678	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-04-09	Elective		840	\N
1679	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-04-16	Elective		840	\N
1680	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-04-16	Elective		840	\N
1681	Ms. Sahar Arshad	Mobile Application Development-I	2K23-BSDS-1A	FoC	Wed	Computing Lab-07	10:00 AM	11:00 AM	Lec	Makeup	2026-02-11			600	\N
1682	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17C	H&S	Fri	CR-15-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-02-13			660	\N
1683	Dr. Sohail Iqbal	Theory of Automata	2K24-BSCS-14D	FoC	Wed	CR-11-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-02-18			840	\N
1684	Dr. Sohail Iqbal	Theory of Automata	2K24-BSCS-14D	FoC	Wed	CR-11-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-18			900	\N
1685	Dr. Muhammad Khuram Shahzad	Parallel and Distributed Computing	2K23-BSCS-13A	FoC	Fri	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-02-13			840	\N
1686	Dr. Muhammad Khuram Shahzad	Parallel and Distributed Computing	2K23-BSCS-13A	FoC	Fri	Computing Lab-01	02:00 PM	03:00 PM	Lec	Makeup	2026-02-20			840	\N
1687	Dr. Muhammad Khuram Shahzad	Parallel and Distributed Computing	2K23-BSCS-13B	FoC	Fri	Computing Lab-01	12:00 PM	01:00 PM	Lec	Makeup	2026-02-13			720	\N
1688	Dr. Muhammad Khuram Shahzad	Parallel and Distributed Computing	2K23-BSCS-13B	FoC	Fri	Computing Lab-01	12:00 PM	01:00 PM	Lec	Makeup	2026-02-20			720	\N
1689	Dr. Muhammad Saad Zia	Electronic Circuit Design	2K24-BEE-16C	ECE	Mon	CR-01-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-16			960	\N
1690	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Mon	CR-26-Acad Block	11:00 AM	12:00 PM	Lec	Makeup	2026-02-16	Elective		660	\N
1691	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Mon	CR-26-Acad Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-16	Elective		720	\N
1692	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14A	ECE	Wed	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-04	Elective		0	\N
1693	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14B	ECE	Wed	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-04	Elective		0	\N
1694	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14C	ECE	Wed	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-04	Elective		0	\N
1695	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14D	ECE	Wed	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-04	Elective		0	\N
1696	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-04	Elective		0	\N
1697	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-04	Elective		0	\N
1698	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-04	Elective		0	\N
1699	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-04	Elective		0	\N
1700	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Wed	CR-18-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-04			0	\N
1701	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Wed	CR-18-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-04			0	\N
1702	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Wed	CR-19-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-04			0	\N
1703	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Wed	CR-20-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-04			0	\N
1704	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Wed	CR-19-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-04			0	\N
1705	Dr. Mehwish Awan	Deep Learning	2K23-BSCS-13C	FoC	Wed	CR-28-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-04			0	\N
1706	Dr. Mehwish Awan	Deep Learning	2K23-BSCS-13C	FoC	Wed	CR-28-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-04			0	\N
1707	Ms. Sahar Arshad	Mobile Application Development-I	2K23-BSDS-1A	FoC	Fri	CR-28-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1708	Ms. Sahar Arshad	Mobile Application Development-I	2K23-BSDS-1A	FoC	Fri	CR-28-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1709	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAi-2A	FoC	Fri	CR-01-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1710	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Fri	CR-03-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1711	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Fri	CR-03-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1712	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Fri	CR-03-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1713	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K25-BCE-1A	H&S	Fri	CR-13-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1714	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K25-BCE-1A	H&S	Fri	CR-13-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-02-06			900	\N
1715	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Fri	CR-18-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1716	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Fri	CR-19-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1717	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Fri	CR-20-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1718	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Fri	CR-19-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1719	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13C	FoC	Fri	CR-26-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1720	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13C	FoC	Fri	CR-26-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1721	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Fri	CR-27-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1722	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Fri	CR-27-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-06			0	\N
1723	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Mon	CR-19-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-09			0	\N
1724	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Mon	CR-20-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-09			0	\N
1725	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Tue	CR-01-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-02-10	Elective		900	\N
1726	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Tue	CR-01-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-10	Elective		0	\N
1727	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Tue	CR-01-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-02-10	Elective		900	\N
1728	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Tue	CR-01-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-10	Elective		0	\N
1729	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Tue	CR-01-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-02-10	Elective		900	\N
1730	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Tue	CR-01-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-10	Elective		0	\N
1731	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Tue	CR-01-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-02-10	Elective		900	\N
1732	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Tue	CR-01-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-10	Elective		0	\N
1733	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Tue	CR-08-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-10			0	\N
1734	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Tue	CR-08-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-02-10			900	\N
1735	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Tue	CR-16-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-10			0	\N
1736	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Tue	CR-16-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-10			0	\N
1737	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15B	H&S	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-11			0	\N
1738	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15C	H&S	Wed	CR-08-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-11			0	\N
1739	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-11	Elective		0	\N
1740	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-11	Elective		0	\N
1741	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-11	Elective		0	\N
1742	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-11	Elective		0	\N
1743	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Wed	CR-17-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-11			0	\N
1744	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Wed	CR-17-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-11			0	\N
1745	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Wed	CR-20-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-11			0	\N
1746	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Wed	CR-20-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-11			0	\N
1747	Dr. Sidra Shafiq	Applied Physics	2K24-BSAi-1A	H&S	Thu	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-12			0	\N
1748	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	12:00 AM	01:00 AM	Lab	Missed	2026-02-12			0	\N
1749	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	03:00 PM	04:00 PM	Lab	Missed	2026-02-12			900	\N
1750	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	12:00 AM	01:00 AM	Lab	Missed	2026-02-12			0	\N
1751	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Thu	CR-19-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-12			0	\N
1752	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Thu	CR-19-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-12			0	\N
1753	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSDS-3A	H&S	Thu	CR-27-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-12			0	\N
1754	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSDS-3A	H&S	Thu	CR-27-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-12			0	\N
1755	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSCS-15E	H&S	Thu	CR-27-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-12			0	\N
1756	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSCS-15E	H&S	Thu	CR-27-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-12			0	\N
1757	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Fri	CR-12-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-13	Elective		0	\N
1758	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Fri	CR-12-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-13	Elective		0	\N
1759	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15A	H&S	Mon	CR-02-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-16			0	\N
1760	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Mon	CR-08-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-16			0	\N
1761	Dr. Saira Zainab	Linear Algebra and ODEs	2K25-BESE-16A	H&S	Mon	CR-09-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-16			0	\N
1762	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BCE-1A	H&S	Mon	CR-13-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-16			0	\N
1763	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Mon	CR-19-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-16			0	\N
1764	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Mon	CR-20-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-16			0	\N
1765	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Mon	CR-22-SMRIMMS	12:00 AM	01:00 AM	Lec	Missed	2026-02-16			0	\N
1766	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Mon	CR-22-SMRIMMS	12:00 AM	01:00 AM	Lec	Missed	2026-02-16			0	\N
1767	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16A	H&S	Tue	CR-05-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-02-17			900	\N
1768	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16A	H&S	Tue	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-17			0	\N
1769	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16B	H&S	Tue	CR-06-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-17			0	\N
1770	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17A	H&S	Wed	CR-14-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-18			0	\N
1771	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17A	H&S	Wed	CR-14-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-18			0	\N
1772	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Wed	CR-24-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-18			0	\N
1773	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Wed	CR-24-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-18			0	\N
1774	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	02:00 PM	03:00 PM	Lec	Missed	2026-02-18			840	\N
1775	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	03:00 PM	04:00 PM	Lec	Missed	2026-02-18			900	\N
1776	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-18			0	\N
1777	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-18			0	\N
1778	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13B	FoC	Thu	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-19			0	\N
1779	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13B	FoC	Thu	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-19			0	\N
1780	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14A	H&S	Fri	CR-21-SMRIMMS	12:00 AM	01:00 AM	Lec	Missed	2026-02-20			0	\N
1781	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14B	H&S	Fri	CR-21-SMRIMMS	12:00 AM	01:00 AM	Lec	Missed	2026-02-20			0	\N
1782	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14C	H&S	Fri	CR-21-SMRIMMS	12:00 AM	01:00 AM	Lec	Missed	2026-02-20			0	\N
1783	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13A	FoC	Fri	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-20			0	\N
1784	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13B	FoC	Fri	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-20			0	\N
1785	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13B	FoC	Mon	CR-26-Acad Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-09			540	\N
1786	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13B	FoC	Mon	CR-26-Acad Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-09			600	\N
1787	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-11			960	\N
1788	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13A	FoC	Tue	Lecture Hall-PG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-10			540	\N
1789	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13B	FoC	Tue	Lecture Hall-PG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-10			540	\N
1790	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14A	H&S	Fri	CR-09-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-20			540	\N
1791	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14A	H&S	Fri	CR-09-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-20			600	\N
1792	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14C	H&S	Fri	CR-09-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-13			540	\N
1793	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14C	H&S	Fri	CR-09-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-13			600	\N
1794	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Wed	CR-02-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-11			720	\N
1795	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Wed	CR-02-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-18			720	\N
1796	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13C	FoC	Wed	Lecture Hall-PG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-11			960	\N
1797	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13D	FoC	Wed	Lecture Hall-PG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-11			960	\N
1798	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Tue	CR-18-IAEC	04:00 PM	05:00 PM	Lec	Makeup	2026-02-10			960	\N
1799	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Fri	CR-18-IAEC	02:00 PM	03:00 PM	Lec	Makeup	2026-02-13			840	\N
1800	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Fri	CR-18-IAEC	03:00 PM	04:00 PM	Lec	Makeup	2026-02-13			900	\N
1801	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Tue	CR-18-IAEC	04:00 PM	05:00 PM	Lec	Makeup	2026-02-17			960	\N
1802	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Fri	CR-18-IAEC	02:00 PM	03:00 PM	Lec	Makeup	2026-02-20			840	\N
1803	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Fri	CR-18-IAEC	03:00 PM	04:00 PM	Lec	Makeup	2026-02-20			900	\N
1804	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Tue	Computing Lab-05	11:00 AM	12:00 PM	Lec	Makeup	2026-02-10			660	\N
1805	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Tue	Computing Lab-05	12:00 PM	01:00 PM	Lec	Makeup	2026-02-10			720	\N
1806	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Tue	Computing Lab-05	12:00 PM	01:00 PM	Lec	Makeup	2026-02-17			720	\N
1807	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15B	FoC	Tue	Computing Lab-05	02:00 PM	03:00 PM	Lec	Makeup	2026-02-10			840	\N
1808	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15B	FoC	Tue	Computing Lab-05	02:00 PM	03:00 PM	Lec	Makeup	2026-02-17			840	\N
1809	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Thu	CR-06-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-12			600	\N
1810	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15A	H&S	Tue	Lecture Hall-IAEC	04:00 PM	05:00 PM	Lec	Makeup	2026-02-17			960	\N
1811	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15A	H&S	Wed	Lecture Hall-IAEC	04:00 PM	05:00 PM	Lec	Makeup	2026-02-18			960	\N
1812	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSCS-15E	H&S	Thu	CR-09-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-12			960	\N
1813	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSDS-3A	H&S	Thu	CR-09-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-12			960	\N
1814	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSCS-15E	H&S	Fri	CR-11-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-13			720	\N
1815	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSDS-3A	H&S	Fri	CR-11-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-13			720	\N
1816	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Wed	CR-02-UG Block	01:00 PM	02:00 PM	Lec	Makeup	2026-02-18	Elective		780	\N
1817	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Wed	CR-02-UG Block	01:00 PM	02:00 PM	Lec	Makeup	2026-02-18	Elective		780	\N
1818	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Wed	CR-02-UG Block	01:00 PM	02:00 PM	Lec	Makeup	2026-02-18	Elective		780	\N
1819	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Wed	CR-02-UG Block	01:00 PM	02:00 PM	Lec	Makeup	2026-02-18	Elective		780	\N
1820	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14A	FoC	Thu	CR-23-Acad Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-12			900	\N
1821	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14C	H&S	Fri	CR-09-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-13			900	\N
1822	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14C	H&S	Fri	CR-09-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-13			960	\N
1823	Dr. Rabia Irfan	Introduction to Data Science	2K24-BSDS-2A	FoC	Thu	CR-12-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-19			900	\N
1824	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14B	FoC	Fri	CR-24-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-13			720	\N
1825	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Fri	Computing Lab-04	12:00 PM	01:00 PM	Lec	Makeup	2026-02-13			720	\N
1826	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Fri	Computing Lab-04	02:00 PM	03:00 PM	Lec	Makeup	2026-02-13			840	\N
1827	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Mon	Control System Lab	12:00 PM	01:00 PM	Lec	Makeup	2026-02-16	Elective		720	\N
1828	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Mon	Control System Lab	12:00 PM	01:00 PM	Lec	Makeup	2026-02-23	Elective		720	\N
1829	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14A	FoC	Fri	CR-05-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-02-20			840	\N
1830	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14A	FoC	Fri	CR-05-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-20			900	\N
1831	Dr. Hina Munir Dutt	Differential Equations	2K25-BEE-17D	H&S	Mon	CR-11-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-16			900	\N
1832	Dr. Rabia Irfan	Data Warehousing and Business Intelligence	2K23-BSDS-1A	FoC	Thu	CR-14-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-19			960	\N
1833	Dr. Rabia Irfan	Data Warehousing and Business Intelligence	2K23-BSDS-1A	FoC	Thu	CR-14-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-26			960	\N
1834	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Tue	EMS Lab	12:00 PM	01:00 PM	Lec	Makeup	2026-02-17			720	\N
1835	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Tue	EMS Lab	04:00 PM	05:00 PM	Lec	Makeup	2026-02-17			960	\N
1836	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14B	FoC	Mon	Computing Lab-06	12:00 PM	01:00 PM	Lec	Makeup	2026-02-16			720	\N
1837	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Tue	Computing Lab-06	02:00 PM	03:00 PM	Lec	Makeup	2026-02-17			840	\N
1838	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Thu	Computing Lab-11	09:00 AM	10:00 AM	Lec	Makeup	2026-02-26			540	\N
1839	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Fri	CR-01-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-02-20	Elective		660	\N
1840	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Fri	CR-01-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-20	Elective		720	\N
1841	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Fri	CR-01-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-02-20	Elective		660	\N
1842	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Fri	CR-01-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-20	Elective		720	\N
1843	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Fri	CR-01-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-02-20	Elective		660	\N
1844	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Fri	CR-01-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-20	Elective		720	\N
1845	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Fri	CR-01-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-02-20	Elective		660	\N
1846	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Fri	CR-01-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-02-20	Elective		720	\N
1847	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Fri	CR-01-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-27	Elective		540	\N
1848	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Fri	CR-01-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-27	Elective		600	\N
1849	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Fri	CR-01-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-27	Elective		540	\N
1850	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Fri	CR-01-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-27	Elective		600	\N
1851	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Fri	CR-01-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-27	Elective		540	\N
1852	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Fri	CR-01-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-27	Elective		600	\N
1853	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Fri	CR-01-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-27	Elective		540	\N
1854	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Fri	CR-01-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-27	Elective		600	\N
1855	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Fri	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-20			900	\N
1856	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Fri	CR-20-IAEC	02:00 PM	03:00 PM	Lec	Makeup	2026-02-20			840	\N
1857	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Thu	CR-03-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-26			540	\N
1858	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Thu	CR-25-Acad Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-26			960	\N
1859	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Mon	CR-26-Acad Block	09:00 AM	10:00 AM	Lec	Makeup	2026-02-23			540	\N
1860	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Mon	CR-26-Acad Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-23			600	\N
1861	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Fri	Computing Lab-04	12:00 PM	01:00 PM	Lec	Makeup	2026-02-20			720	\N
1862	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Fri	Computing Lab-04	02:00 PM	03:00 PM	Lec	Makeup	2026-02-20			840	\N
1863	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17A	H&S	Thu	Lecture Hall-PG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-02-19			840	\N
1864	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17A	H&S	Thu	Lecture Hall-PG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-02-19			900	\N
1865	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Thu	CR-06-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-02-19			600	\N
1866	Mr. Maajid Maqbool	Entrepreneurship	2K22-BEE-14B	FoC	Tue	CR-24-Acad Block	04:00 PM	05:00 PM	Lec	Makeup	2026-02-17			960	\N
1867	Dr. Naima Iltaaf	Web Technologies	2K24-BSAi-1A	FoC	Fri	Computing Lab-08	10:00 AM	11:00 AM	Lec	Makeup	2026-02-20			600	\N
1868	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Wed	CR-05-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-02-18			840	\N
1869	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Tue	CR-13-UG Block	03:00 PM	04:00 PM	Lab	Makeup	2026-02-17			900	\N
1870	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Tue	CR-13-UG Block	03:00 PM	04:00 PM	Lab	Makeup	2026-02-24			900	\N
1871	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Tue	CR-13-UG Block	04:00 PM	05:00 PM	Lab	Makeup	2026-02-24			960	\N
1872	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14B	H&S	Mon	Lecture Hall-PG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-23			0	\N
1873	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14A	H&S	Mon	CR-04-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-23			0	\N
1874	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14C	H&S	Mon	Lecture Hall-PG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-23			0	\N
1875	Dr. Saira Zainab	Linear Algebra and ODEs	2K25-BESE-16A	H&S	Tue	CR-02-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-17			0	\N
1876	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BCE-1A	H&S	Tue	CR-04-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-17			0	\N
1877	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K23-BSDS-1A	H&S	Tue	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-17			0	\N
1878	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K23-BSDS-1A	H&S	Tue	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-17			0	\N
1879	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14B	FoC	Tue	CR-18-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-17			0	\N
1880	Dr. Naima Iltaaf	Web Technologies	2K24-BSCS-14D	FoC	Tue	Computing Lab-06	12:00 AM	01:00 AM	Lec	Makeup	2026-02-17			0	\N
1881	Dr. Naima Iltaaf	Web Technologies	2K24-BSCS-14D	FoC	Tue	Computing Lab-06	12:00 AM	01:00 AM	Lec	Makeup	2026-02-17			0	\N
1882	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Fri	CR-02-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
1883	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Fri	CR-02-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06			0	\N
1884	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Fri	CR-20-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
1885	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Fri	CR-20-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06			0	\N
1886	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1887	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1888	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1889	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1890	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1891	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1892	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1893	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1894	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1895	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1896	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1897	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1898	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1899	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1900	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1901	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1902	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1903	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1904	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1905	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1906	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1907	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1908	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1909	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27	Elective		0	\N
1910	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1911	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1912	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1913	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1914	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1915	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1916	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1917	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1918	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1919	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1920	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1921	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1922	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1923	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1924	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1925	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1926	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1927	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1928	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1929	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1930	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1931	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1932	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1933	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Fri	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06	Elective		0	\N
1934	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Tue	EMS Lab	12:00 AM	01:00 AM	Lec	Makeup	2026-02-24			0	\N
1935	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Thu	CR-12-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-26			0	\N
1936	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Tue	EMS Lab	12:00 AM	01:00 AM	Lec	Makeup	2026-02-24			0	\N
1937	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Thu	CR-10-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-26			0	\N
1938	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Tue	Computing Lab-06	12:00 AM	01:00 AM	Lec	Makeup	2026-02-24			0	\N
1939	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Tue	Computing Lab-06	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03			0	\N
1940	Dr. Sohail Iqbal	Theory of Automata	2K24-BSCS-14D	FoC	Wed	CR-12-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25			0	\N
1941	Dr. Sohail Iqbal	Theory of Automata	2K24-BSCS-14D	FoC	Wed	CR-12-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25			0	\N
1942	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Thu	Computing Lab-06	12:00 AM	01:00 AM	Lec	Makeup	2026-02-26			0	\N
1943	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Thu	Computing Lab-06	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
1944	Dr. Seemab Latif	Machine Learning	2K24-BSAi-1A	FoC	Wed	Computing Lab-04	12:00 AM	01:00 AM	Lec	Makeup	2026-01-28			0	\N
1945	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Mon	CR-18-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-23			0	\N
1946	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Mon	CR-18-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-02-23			0	\N
1947	Dr. Hina Munir Dutt	Differential Equations	2K25-BEE-17D	H&S	Wed	CR-15-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-25			0	\N
1948	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-25	Elective		0	\N
1949	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-25	Elective		0	\N
1950	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13B	FoC	Wed	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-25	Elective		0	\N
1951	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13B	FoC	Wed	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-25	Elective		0	\N
1952	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13C	FoC	Wed	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-25	Elective		0	\N
1953	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13C	FoC	Wed	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-25	Elective		0	\N
1954	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13D	FoC	Wed	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-25	Elective		0	\N
1955	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13D	FoC	Wed	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-25	Elective		0	\N
1956	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13E	FoC	Wed	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-25	Elective		0	\N
1957	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13E	FoC	Wed	CR-25-Acad Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-25	Elective		0	\N
1958	Ms. Hadia Tahir	Computer Vision	2k23-BSDS-1A	FoC	Thu	Computing Lab-12	12:00 AM	01:00 AM	Lab	Missed	2026-02-26			0	\N
1959	Dr. Muhammad Yousaf	Engineering Economics	2k22-BSCS-12B	H&S	Fri	Lec Hall-PG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-27			0	\N
1960	Dr. Muhammad Yousaf	Engineering Economics	2k22-BSCS-12C	H&S	Fri	CR-08-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-02-27			0	\N
1961	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12B	H&S	Thu	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-26			0	\N
1962	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12C	H&S	Thu	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-26			0	\N
1963	Dr. Samia Tahir	Expository Writing	2K24-BSCS-14D	H&S	Thu	CR-18-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-26			0	\N
1964	Dr. Samia Tahir	Expository Writing	2K24-BSAi-1A	H&S	Fri	CR-06-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
1965	Dr. Samia Tahir	Expository Writing	2K24-BSAi-1A	H&S	Fri	CR-06-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
1966	Dr. Samia Tahir	Expository Writing	2K24-BSDS-2A	H&S	Fri	CR-06-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
1967	Dr. Samia Tahir	Expository Writing	2K24-BSDS-2A	H&S	Fri	CR-06-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
1968	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14A	ECE	Wed	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25	Elective		0	\N
1969	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14A	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25	Elective		0	\N
1970	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14A	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25	Elective		0	\N
1971	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14B	ECE	Wed	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25	Elective		0	\N
1972	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14B	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25	Elective		0	\N
1973	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14B	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25	Elective		0	\N
1974	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14C	ECE	Wed	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25	Elective		0	\N
1975	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14C	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25	Elective		0	\N
1976	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14C	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25	Elective		0	\N
1977	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14D	ECE	Wed	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25	Elective		0	\N
1978	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14D	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25	Elective		0	\N
1979	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14D	ECE	Wed	CR-11-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25	Elective		0	\N
1980	Dr. Saira Zainab	Linear Algebra and ODEs	2K25-BESE-16A	H&S	Thu	CR-04-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-26			0	\N
1981	Dr. Saira Zainab	Linear Algebra and ODEs	2K25-BESE-16B	H&S	Wed	CR-03-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25			0	\N
1982	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BCE-1A	H&S	Fri	CR-13-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
1983	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16A	H&S	Fri	CR-01-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
1984	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16A	H&S	Fri	CR-01-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
1985	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16B	H&S	Fri	CR-01-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
1986	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16B	H&S	Fri	CR-01-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
1987	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Wed	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25			0	\N
1988	Dr. Muhammad Mustafa Tahseen	Electromagnetic Field Theory	2K24-BEE-16B	ECE	Thu	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-26			0	\N
1989	Dr. Muhammad Mustafa Tahseen	Electromagnetic Field Theory	2K24-BEE-16B	ECE	Thu	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-26			0	\N
1990	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15D	ECE	Wed	CR-13-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-25			0	\N
1991	Dr. Samia Tahir	Expository Writing	2K24-BSCS-14D	H&S	Wed	CR-16-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-02-04			0	\N
1992	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14C	ECE	Mon	CR-16-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-02			0	\N
1993	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14D	ECE	Thu	CR-18-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
1994	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14D	ECE	Thu	CR-18-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
1995	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14C	ECE	Mon	CR-16-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-02			0	\N
1996	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14A	FoC	Thu	CR-23-Acad Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
1997	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14A	FoC	Thu	CR-23-Acad Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
1998	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14B	FoC	Wed	CR-24-Acad Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-04			0	\N
1999	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14B	FoC	Wed	CR-24-Acad Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-04			0	\N
2000	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16B	H&S	Fri	CR-12-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
2001	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16B	H&S	Fri	CR-12-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
2002	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Mon	CR-02-UG Block	12:00 AM	01:00 AM	Lab	Makeup	2026-03-02			0	\N
2003	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Fri	CR-11-UG Block	12:00 AM	01:00 AM	Lab	Makeup	2026-02-27			0	\N
2004	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Tue	CR-10-UG Block	12:00 AM	01:00 AM	Lab	Makeup	2026-03-03			0	\N
2005	Mr. Maajid Maqbool	Entrepreneurship	2K23-BESE-14B	FoC	Fri	CR-02-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
2006	Mr. Maajid Maqbool	Entrepreneurship	2K22-BEE-14B	FoC	Fri	CR-02-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-02-27			0	\N
2007	Dr. Qaiser Riaz	Web Technologies	2K24-BSCS-14A	FoC	Mon	Computing Lab-06	12:00 AM	01:00 AM	Lec	Makeup	2026-03-02			0	\N
2008	Dr. Qaiser Riaz	Web Technologies	2K24-BSCS-14A	FoC	Mon	Computing Lab-06	12:00 AM	01:00 AM	Lec	Makeup	2026-03-02			0	\N
2009	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Mon	Embedded Systems Lab	12:00 AM	01:00 AM	Lec	Makeup	2026-03-02	Elective		0	\N
2010	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Mon	Embedded Systems Lab	12:00 AM	01:00 AM	Lec	Makeup	2026-03-02	Elective		0	\N
2011	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Mon	Embedded Systems Lab	12:00 AM	01:00 AM	Lec	Makeup	2026-03-02	Elective		0	\N
2012	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Mon	Embedded Systems Lab	12:00 AM	01:00 AM	Lec	Makeup	2026-03-02	Elective		0	\N
2013	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSDS-3A	FoC	Mon	Computing Lab-02	12:00 AM	01:00 AM	Lec	Makeup	2026-03-02			0	\N
2014	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Mon	Computing Lab-05	12:00 AM	01:00 AM	Lec	Makeup	2026-03-02			0	\N
2015	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Mon	Computing Lab-01	12:00 AM	01:00 AM	Lec	Makeup	2026-03-02	Elective		0	\N
2016	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Mon	Computing Lab-01	12:00 AM	01:00 AM	Lec	Makeup	2026-03-02	Elective		0	\N
2017	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Mon	CR-01-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-02			0	\N
2018	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13A	FoC	Tue	Computing Lab-12	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03	Elective		0	\N
2019	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13A	FoC	Tue	Computing Lab-12	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03	Elective		0	\N
2020	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13B	FoC	Tue	Computing Lab-12	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03	Elective		0	\N
2021	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13B	FoC	Tue	Computing Lab-12	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03	Elective		0	\N
2022	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13C	FoC	Tue	Computing Lab-12	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03	Elective		0	\N
2023	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13C	FoC	Tue	Computing Lab-12	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03	Elective		0	\N
2024	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13D	FoC	Tue	Computing Lab-12	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03	Elective		0	\N
2025	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13D	FoC	Tue	Computing Lab-12	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03	Elective		0	\N
2026	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13E	FoC	Tue	Computing Lab-12	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03	Elective		0	\N
2027	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13E	FoC	Tue	Computing Lab-12	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03	Elective		0	\N
2028	Dr. Muhammad Bilal Ali	Advanced Database Management Systems	2K24-BSCS-14A	FoC	Tue	CR-21-SMRIMMS	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03			0	\N
2029	Dr. Muhammad Daud Abdullah Asif	Machine Learning	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03			0	\N
2030	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Tue	Computing Lab-01	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03			0	\N
2031	Dr. Hina Munir Dutt	Differential Equations	2K25-BEE-17D	H&S	Tue	CR-19-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-03			0	\N
2032	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Tue	CR-13-UG Block	12:00 AM	01:00 AM	Lab	Makeup	2026-03-03			0	\N
2033	Dr. Muhammad Daud Abdullah Asif	Object Oriented Programming	2K25-BESE-16B	FoC	Wed	CR-10-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-04			0	\N
2034	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Wed	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-04			0	\N
2035	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15D	ECE	Wed	CR-13-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-04			0	\N
2036	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Wed	CR-24-Acad Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-04			0	\N
2037	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16B	ECE	Wed	CR-08-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-04			0	\N
2038	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Wed	CR-02-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-04			0	\N
2039	Dr. Junaid Younas	Deep Learning	2K23-BSCS-13A	FoC	Thu	Computing Lab-02	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
2040	Dr. Junaid Younas	Deep Learning	2K23-BSCS-13A	FoC	Thu	Computing Lab-02	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
2041	Dr. Seemab Latif	Machine Learning	2K24-BSAi-1A	FoC	Thu	Computing Lab-04	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
2042	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Thu	CR-12-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
2043	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Thu	CR-10-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
2044	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15C	H&S	Thu	Lecture Hall-PG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
2045	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15C	H&S	Thu	Lecture Hall-PG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
2046	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAi-2A	FoC	Thu	Computing Lab-01	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
2047	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12B	H&S	Thu	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
2048	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12C	H&S	Thu	Lecture Hall-IAEC	12:00 AM	01:00 AM	Lec	Makeup	2026-03-05			0	\N
2049	Dr. Samia Tahir	Expository Writing	2K24-BSAi-1A	H&S	Fri	CR-01-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06			0	\N
2050	Dr. Samia Tahir	Expository Writing	2K24-BSDS-2A	H&S	Fri	CR-01-UG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06			0	\N
2051	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15B	H&S	Fri	Lecture Hall-PG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06			0	\N
2052	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15B	H&S	Fri	Lecture Hall-PG Block	12:00 AM	01:00 AM	Lec	Makeup	2026-03-06			0	\N
2053	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15C	H&S	Mon	CR-03-UG Block	12:00 AM	01:00 AM	Lab	Missed	2026-03-02			0	\N
2054	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15C	H&S	Mon	CR-03-UG Block	12:00 AM	01:00 AM	Lab	Missed	2026-03-02			0	\N
2055	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15C	H&S	Mon	CR-03-UG Block	12:00 AM	01:00 AM	Lab	Missed	2026-03-02			0	\N
2056	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15D	H&S	Mon	CR-03-UG Block	12:00 AM	01:00 AM	Lab	Missed	2026-03-02			0	\N
2057	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15D	H&S	Mon	CR-03-UG Block	12:00 AM	01:00 AM	Lab	Missed	2026-03-02			0	\N
2058	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15D	H&S	Mon	CR-03-UG Block	12:00 AM	01:00 AM	Lab	Missed	2026-03-02			0	\N
2059	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	FoC	Mon	CR-10-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-03-02			0	\N
2060	Dr. Qaiser Riaz	Web Technologies	2K24-BSCS-14A	FoC	Tue	CR-21-SMRIMMS	12:00 AM	01:00 AM	Lec	Missed	2026-03-03			0	\N
2061	Dr. Qaiser Riaz	Web Technologies	2K24-BSCS-14A	FoC	Tue	CR-21-SMRIMMS	12:00 AM	01:00 AM	Lec	Missed	2026-03-03			0	\N
2062	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	12:00 AM	01:00 AM	Lab	Missed	2026-03-04			0	\N
2063	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	12:00 AM	01:00 AM	Lab	Missed	2026-03-04			0	\N
2064	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	12:00 AM	01:00 AM	Lab	Missed	2026-03-04			0	\N
2065	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Wed	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-03-04	Elective		0	\N
2066	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Wed	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-03-04	Elective		0	\N
2067	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Wed	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-03-04	Elective		0	\N
2068	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Wed	CR-05-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-03-04	Elective		0	\N
2069	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16C	ECE	Thu	CR-07-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-03-05			0	\N
2070	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16D	ECE	Thu	CR-08-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-03-05			0	\N
2071	Dr. Samia Tahir	Expository Writing	2K24-BSCS-14D	H&S	Thu	CR-18-IAEC	12:00 AM	01:00 AM	Lec	Missed	2026-03-05			0	\N
2072	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12B	H&S	Fri	Lecture Hall-PG	12:00 AM	01:00 AM	Lec	Missed	2026-03-06			0	\N
2073	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12C	H&S	Fri	CR-08-UG Block	12:00 AM	01:00 AM	Lec	Missed	2026-03-06			0	\N
2074	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15D	H&S	Mon	CR-07	12:00 AM	01:00 AM	Lab	Late	2026-01-19			0	\N
2075	Dr. Neelma Riaz	Functional English	2k25-BESE-16A	H&S	Mon	CR-07	12:00 AM	01:00 AM	Lec	Late	2026-01-19			0	\N
2076	Mr. Ahsan Azhar	Electrical Network Analysis	2k25-BEE-17A	ECE	Mon	CR-07	12:00 AM	01:00 AM	Lec	Late	2026-01-19			0	\N
2077	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Mon	CR-07	12:00 AM	01:00 AM	Lec	Late	2026-01-19			0	\N
2078	Mr. Saif Ullah	Understanding of Quran II	2k25-BESE-16A	H&S	Wed	CR-07-UG Block	12:00 AM	01:00 AM	Lab	Late	2026-01-21			0	\N
2079	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Wed	CR-07	12:00 AM	01:00 AM	Lec	Late	2026-01-21			0	\N
2080	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14D	ECE	Wed	CR-07	12:00 AM	01:00 AM	Lec	Late	2026-01-21			0	\N
2081	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSDS-3A	FoC	Mon	Computing Lab-01	12:00 AM	01:00 AM	Lab	Late	2026-01-19			0	\N
2082	Dr. Neelma Riaz	Functional English	2k25-BESE-16A	H&S	Mon	CR-08	12:00 AM	01:00 AM	Lec	Late	2026-01-26			0	\N
2083	Dr. Neelma Riaz	Expository Writing	2k24-BEE-16D	H&S	Tue	CR-08	12:00 AM	01:00 AM	Lec	Late	2026-01-27			0	\N
2084	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	ECE	Tue	CR-08	12:00 AM	01:00 AM	Lec	Late	2026-01-27			0	\N
2085	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2k24-BEE-16C	ECE	Wed	CR-08	12:00 AM	01:00 AM	Lec	Late	2026-01-28			0	\N
2086	Ms. Hina Yousaf	Expository Writing	2k24-BSCS-14B	H&S	Wed	CR-08	12:00 AM	01:00 AM	Lec	Late	2026-01-28			0	\N
2087	Ms. Naema Asif	Mobile Application Development	2k22-BESE-13A	FoC	Mon	CR-08	12:00 AM	01:00 AM	Lec	Late	2026-02-02	Elective		0	\N
2088	Ms. Naema Asif	Mobile Application Development	2k22-BESE-13B	FoC	Mon	CR-08	12:00 AM	01:00 AM	Lec	Late	2026-02-02	Elective		0	\N
2089	Dr. Nauman Anwar Baig	Digital Signal Processing	2k23-BEE-15C	ECE	Mon	CR-08	12:00 AM	01:00 AM	Lec	Late	2026-02-02			0	\N
2090	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Tue	CR-08	12:00 AM	01:00 AM	Lab	Late	2026-02-03			0	\N
2091	Mr. Yaruq Nadeem	Entrepreneurship	2k22-BEE-14A	H&S	Tue	CR-08	12:00 AM	01:00 AM	Lec	Late	2026-02-03			0	\N
2092	Mr. Hafiz Siddiqe	Understanding of Quran II	2K25-BSAI-2A	H&S	Fri	CR-01	12:00 AM	01:00 AM	Lab	Late	2026-02-06			0	\N
2093	Dr. Farkhanda Afzal	Multivariable Calculus	2k25-BSCS-15D	H&S	Fri	CR-06	12:00 AM	01:00 AM	Lec	Late	2026-02-06			0	\N
2094	Dr. Ayesha Hakim	Advanced Database Management Systems	2k24-BSCS-14D	FoC	Mon	CR-22	12:00 AM	01:00 AM	Lec	Late	2026-02-09			0	\N
2095	Dr. Sarosh Tahir	Object Oriented Programming	2k25-BSCS-15E	FoC	Tue	CR-04	12:00 AM	01:00 AM	Lec	Late	2026-02-10			0	\N
2096	Mr. Habeel Ahmed	Electrical Network Analysis	2k25-BEE-17D	ECE	Tue	CR-07	12:00 AM	01:00 AM	Lec	Late	2026-02-10			0	\N
2097	Dr. Ahmed Naeem	Logic and Sequential Circuit Design	2K25-BCE-1A	ECE	Tue	CR-13	12:00 AM	01:00 AM	Lec	Late	2026-02-10			0	\N
2098	Dr. Muhammad Imran Malik	Deep Learning	2k23-BSCS-13B	FoC	Wed	CR-05	12:00 AM	01:00 AM	Lec	Late	2026-02-11			0	\N
2099	Dr. Arshad Siddiqui	Linear Algebra	2k24-BEE-16C	H&S	Wed	CR-07	12:00 AM	01:00 AM	Lec	Late	2026-02-11			0	\N
2100	Dr. Rizwan Ahmad	Communication Systems	2k23-BEE-15D	ECE	Wed	CR-18	12:00 AM	01:00 AM	Lec	Late	2026-02-11			0	\N
2101	Dr. Muhammad Ahmad Rathore	Compiler Construction	2k23-BSCS-13B	FoC	Wed	CR-24	12:00 AM	01:00 AM	Lec	Late	2026-02-11			0	\N
2102	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2k25-BESE-16A	FoC	Thu	CR-07	12:00 AM	01:00 AM	Lec	Late	2026-02-12			0	\N
2103	Syeda Rabia Shaheen	Principles of Sociology	2k22-BSCS-12A	H&S	Thu	Lec Hall IAEC	12:00 AM	01:00 AM	Lec	Late	2026-02-12			0	\N
2104	Mr. Hafiz Siddiqe	Understanding of Quran II	2K25-BSAI-2A	H&S	Fri	CR-01	12:00 AM	01:00 AM	Lab	Late	2026-02-13			0	\N
2105	Ms. Nikhar Azhar	Deep Learning	2k23-BSCS-13E	FoC	Fri	CR-27	12:00 AM	01:00 AM	Lec	Late	2026-02-13			0	\N
2106	Mr. Hafiz Siddiqe	Understanding of Quran II	2K25-BSAI-2A	H&S	Fri	CR-01	12:00 AM	01:00 AM	Lab	Late	2026-02-13			0	\N
2107	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2k24-BEE-16D	ECE	Mon	CR-08	12:00 AM	01:00 AM	Lec	Late	2026-02-16			0	\N
2108	Dr. Neelma Riaz	Expository Writing	2k24-BEE-16D	H&S	Tue	CR-08	12:00 AM	01:00 AM	Lec	Late	2026-02-17			0	\N
2109	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2k24-BEE-16C	ECE	Wed	CR-07	12:00 AM	01:00 AM	Lec	Late	2026-02-18			0	\N
2110	Ms. Hina Yousaf	Expository Writing	2k24-BSCS-14B	H&S	Wed	CR-21	12:00 AM	01:00 AM	Lec	Late	2026-02-18			0	\N
2111	Dr. Muhammad Moazam Fraz	Large Language Models	2K23-BSDS-1A	FoC	Wed	CR-28	12:00 AM	01:00 AM	Lec	Late	2026-02-18			0	\N
2112	Mr. Hafiz Siddiqe	Understanding of Quran II	2K25-BSAI-2A	H&S	Fri	CR-01	12:00 AM	01:00 AM	Lab	Late	2026-02-20			0	\N
2113	Dr. Arshad Siddiqui	Linear Algebra	2k24-BEE-16C	H&S	Mon	CR-07-UG Block	12:00 AM	01:00 AM	Lec	Late	2026-02-23			0	\N
2114	Dr. Sadiq Amin	Fundamentals of Programming	2K25-BCE-1A	ECE	Mon	CR-13-UG Block	12:00 AM	01:00 AM	Lec	Late	2026-02-23			0	\N
2115	Dr. Sadiq Amin	Computer Programming	2k25-BEE-17A	ECE	Mon	CR-14-UG Block	12:00 AM	01:00 AM	Lec	Late	2026-02-23			0	\N
2116	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Mon	CR-26-Acad Block	12:00 AM	01:00 AM	Lec	Late	2026-02-23			0	\N
2117	Mr. Ahsan Azhar	Electrical Network Analysis	2k25-BEE-17A	ECE	Wed	CR-14-UG Block	12:00 AM	01:00 AM	Lec	Late	2026-02-25			0	\N
2118	Ms. Hina Yousaf	Expository Writing	2k24-BSCS-14B	H&S	Wed	CR-21-SMRIMMS	12:00 AM	01:00 AM	Lec	Late	2026-02-25			0	\N
2119	Dr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14A	ECE	Wed	CR-21-SMRIMMS	12:00 AM	01:00 AM	Lec	Late	2026-02-25			0	\N
2120	Dr. Aimal Tariq Rextin	Object Oriented Programming	2k25-BESE-16A	FoC	Fri	CR-09-UG Block	12:00 AM	01:00 AM	Lec	Late	2026-02-27			0	\N
2121	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K23-BSDS-1A	H&S	Fri	CR-13-UG Block	12:00 AM	01:00 AM	Lec	Late	2026-02-27			0	\N
2122	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	ECE	Fri	CR-15-UG Block	12:00 AM	01:00 AM	Lec	Late	2026-02-27			0	\N
2123	Dr. Rai Sajjad Saif	Linear Algebra	2k25-BSCS-15E	H&S	Mon	CR-04-UG Block	12:00 AM	01:00 AM	Lec	Late	2026-03-02			0	\N
2124	Dr. Farzana Jabeen	Web Technologies	2k24-BSCS-14C	FoC	Mon	CR-18-IAEC	12:00 AM	01:00 AM	Lec	Late	2026-03-02			0	\N
2125	Dr. Nauman Anwar Baig	Digital Signal Processing	2k23-BEE-15C	ECE	Mon	CR-19-IAEC	12:00 AM	01:00 AM	Lec	Late	2026-03-02			0	\N
2126	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAi-2A	FoC	Tue	CR-01-UG Block	12:00 AM	01:00 AM	Lec	Late	2026-03-03			0	\N
2127	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Tue	CR-08-UG Block	12:00 AM	01:00 AM	Lec	Late	2026-03-03			0	\N
2128	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Tue	CR-16-IAEC	12:00 AM	01:00 AM	Lec	Late	2026-03-03			0	\N
2129	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Wed	CR-17-IAEC	12:00 AM	01:00 AM	Lec	Late	2026-03-04			0	\N
2130	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15D	H&S	Thu	CR-02-UG Block	12:00 AM	01:00 AM	Lec	Late	2026-03-05			0	\N
2131	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17C	H&S	Thu	CR-15-UG Block	12:00 AM	01:00 AM	Lec	Late	2026-03-05			0	\N
2132	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Fri	CR-03-UG Block	12:00 AM	01:00 AM	Lec	Late	2026-03-06			0	\N
2133	Mr. Maajid Maqbool	Entrepreneurship	2K23-BESE-14A	FoC	Tue	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-03-17			960	\N
2134	Mr. Maajid Maqbool	Entrepreneurship	2K23-BESE-14B	FoC	Tue	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-03-17			960	\N
2135	Mr. Maajid Maqbool	Entrepreneurship	2K22-BEE-14B	FoC	Tue	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-03-17			960	\N
2136	Dr. Junaid Younas	Deep Learning	2K23-BSCS-13A	FoC	Wed	Lec Hall-PG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-03-18			900	\N
2137	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Wed	Lec Hall-PG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-03-25			840	\N
2138	Mr. Maajid Maqbool	Entrepreneurship	2K22-BEE-14B	FoC	Wed	CR-11-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-03-25			900	\N
2139	Mr. Maajid Maqbool	Entrepreneurship	2K22-BEE-14B	FoC	Wed	CR-11-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-03-25			960	\N
2140	Mr. Maajid Maqbool	Entrepreneurship	2K22-BESE-14A	FoC	Wed	CR-11-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-03-25			960	\N
2141	Mr. Maajid Maqbool	Entrepreneurship	2K22-BESE-14B	FoC	Wed	CR-11-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-03-25			960	\N
2142	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	04:00 PM	05:00 PM	Lec	Makeup	2026-03-25			960	\N
2143	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAi-2A	FoC	Thu	CR-03-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-03-26			600	\N
2144	Dr. Fahad Ahmed Satti	Database Systems	2K25-BSDS-3A	FoC	Thu	Lec Hall-PG Block	01:00 PM	02:00 PM	Lec	Makeup	2026-03-26			780	\N
2145	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Thu	CR-06-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-03-26			840	\N
2146	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17A	H&S	Thu	CR-10-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-03-26			600	\N
2147	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17A	H&S	Thu	CR-10-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-03-26			660	\N
2148	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSAi-2A	ECE	Thu	CR-16-IAEC	02:00 PM	03:00 PM	Lec	Makeup	2026-03-26			840	\N
2149	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSAi-2A	ECE	Thu	CR-16-IAEC	03:00 PM	04:00 PM	Lec	Makeup	2026-03-26			900	\N
2150	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Thu	Lec Hall-PG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-03-26			840	\N
2151	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Thu	Lec Hall-PG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-03-26			960	\N
2152	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Thu	CR-12-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-03-26			840	\N
2153	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Thu	CR-25-Acad Block	04:00 PM	05:00 PM	Lec	Makeup	2026-03-26			960	\N
2154	Dr. Fahad Ahmed Satti	Database Systems	2K25-BSDS-3A	FoC	Thu	CR-09-UG Block	01:00 PM	02:00 PM	Lec	Makeup	2026-03-26			780	\N
2155	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12A	H&S	Thu	Lec Hall-PG Block	01:00 PM	02:00 PM	Lec	Makeup	2026-03-26			780	\N
2156	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12B	H&S	Thu	Lec Hall-PG Block	01:00 PM	02:00 PM	Lec	Makeup	2026-03-26			780	\N
2157	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12C	H&S	Thu	Lec Hall-PG Block	01:00 PM	02:00 PM	Lec	Makeup	2026-03-26			780	\N
2158	Dr. Samia Tahir	Expository Writing	2K24-BSAi-1A	H&S	Fri	CR-02-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-03-27			540	\N
2159	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14D	H&S	Fri	CR-09-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-03-27			540	\N
2160	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14D	H&S	Fri	CR-09-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-03-27			600	\N
2161	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Fri	CR-01-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-03-27			720	\N
2162	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Fri	CR-01-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-03-27			840	\N
2163	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14D	H&S	Fri	CR-09-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-03-27			540	\N
2164	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14D	H&S	Fri	CR-09-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-03-27			600	\N
2165	Dr. Imran Malik	Applied Physics	2K24-BSDS-2A	H&S	Fri	CR-11-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-03-27			720	\N
2166	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14A	FoC	Fri	CR-07-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-03-27			840	\N
2167	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14A	FoC	Fri	CR-07-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-03-27			900	\N
2168	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Mon	Lec Hall-PG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-03-30			840	\N
2169	Dr. Sarosh Tahir	Software Engineering	2K23-BSCS-13E	FoC	Mon	CR-02-UG Block	08:00 AM	09:00 AM	Lec	Makeup	2026-03-30			480	\N
2170	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Mon	CR-26-Acad Block	09:00 AM	10:00 AM	Lec	Makeup	2026-03-30			540	\N
2171	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Mon	CR-26-Acad Block	10:00 AM	11:00 AM	Lec	Makeup	2026-03-30			600	\N
2172	Dr. Imran Malik	Applied Physics	2K24-BSCS-14A	H&S	Mon	CR-04-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-03-30			540	\N
2173	Dr. Imran Malik	Applied Physics	2K24-BSCS-14B	H&S	Mon	CR-16-IAEC	02:00 PM	03:00 PM	Lec	Makeup	2026-03-30			840	\N
2174	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Mon	Seminar Hall-RIMMS	12:00 PM	01:00 PM	Lec	Makeup	2026-03-30	Elective		720	\N
2175	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Mon	Seminar Hall-RIMMS	12:00 PM	01:00 PM	Lec	Makeup	2026-03-30	Elective		720	\N
2176	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Mon	Computing Lab-05	02:00 PM	03:00 PM	Lec	Makeup	2026-03-30			840	\N
2177	Dr. Tahira Anwar Lashari	Principles of Sociology	2K22-BSCS-12C	FoC	Mon	CR-09-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-03-30			840	\N
2178	Dr. Tahira Anwar Lashari	Principles of Sociology	2K22-BSCS-12C	FoC	Mon	CR-09-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-03-30			900	\N
2179	Dr. Sarosh Tahir	Object Oriented Programming	2K25-BSCS-15E	FoC	Tue	CR-22-SMRIMMS	10:00 AM	11:00 AM	Lec	Makeup	2026-03-31			600	\N
2180	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15E	H&S	Tue	CR-21-SMRIMMS	09:00 AM	10:00 AM	Lec	Makeup	2026-03-31			540	\N
2181	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Tue	CR-04-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-03-31			960	\N
2182	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Tue	CR-04-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-03-31			960	\N
2183	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15A	H&S	Wed	Lec Hall-PG Block	05:00 PM	06:00 PM	Lec	Makeup	2026-04-01			1020	\N
2184	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15B	H&S	Wed	Lec Hall-PG Block	05:00 PM	06:00 PM	Lec	Makeup	2026-04-01			1020	\N
2185	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-01			960	\N
2186	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Wed	CR-02-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-04-01			720	\N
2187	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Wed	CR-11-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-04-01			720	\N
2188	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Wed	CR-03-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-01			960	\N
2189	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Wed	CR-03-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-01			960	\N
2190	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16C	H&S	Wed	CR-09-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-01			600	\N
2191	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16D	H&S	Wed	CR-09-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-01			600	\N
2192	Mr. Taufique ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Wed	Lec Hall-IAEC	12:00 PM	01:00 PM	Lec	Makeup	2026-04-01			720	\N
2193	Mr. Taufique ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Wed	Lec Hall-IAEC	01:00 PM	02:00 PM	Lec	Makeup	2026-04-01			780	\N
2194	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Wed	CR-05-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-04-01			840	\N
2195	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Wed	CR-11-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-01			960	\N
2196	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15A	H&S	Thu	Lec Hall-PG Block	05:00 PM	06:00 PM	Lec	Makeup	2026-04-02			1020	\N
2197	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15B	H&S	Thu	Lec Hall-PG Block	05:00 PM	06:00 PM	Lec	Makeup	2026-04-02			1020	\N
2198	Mr. Saeed Afzal	Linear Algebra	2K25-BSAi-2A	H&S	Thu	CR-06-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-04-02			900	\N
2199	Mr. Saeed Afzal	Linear Algebra	2K25-BSAi-2A	H&S	Thu	CR-06-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-02			960	\N
2200	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14A	FoC	Thu	CR-07-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-02			960	\N
2201	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Thu	CR-25-Acad Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-02			960	\N
2202	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Thu	CR-10-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-02			600	\N
2203	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12A	FoC	Thu	CR-02-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-04-02			840	\N
2204	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12B	FoC	Thu	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-04-02			900	\N
2205	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12C	FoC	Thu	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-02			960	\N
2206	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAi-2A	FoC	Thu	Computing Lab-01	10:00 AM	11:00 AM	Lec	Makeup	2026-04-02			600	\N
2207	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Thu	Lec Hall-PG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-04-02			840	\N
2208	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Thu	CR-14-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-02			960	\N
2209	Ms. Ayesha Kanwal	Software Quality Engineering	2K23-BESE-14A	FoC	Thu	Lec Hall-IAEC	03:00 PM	04:00 PM	Lec	Makeup	2026-04-02			900	\N
2210	Ms. Ayesha Kanwal	Software Quality Engineering	2K23-BESE-14B	FoC	Thu	Lec Hall-IAEC	03:00 PM	04:00 PM	Lec	Makeup	2026-04-02			900	\N
2211	Mr. Taufique ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Thu	CR-17-IAEC	11:00 AM	12:00 PM	Lec	Makeup	2026-04-02			660	\N
2212	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15C	H&S	Thu	Lec Hall-PG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-04-02			900	\N
2213	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15C	H&S	Thu	Lec Hall-PG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-02			960	\N
2214	Dr. Sarosh Tahir	Object Oriented Programming	2K25-BSCS-15E	FoC	Thu	CR-16-IAEC	10:00 AM	11:00 AM	Lec	Makeup	2026-04-02			600	\N
2215	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14A	H&S	Thu	CR-01-UG Block	09:00 AM	10:00 AM	Lec	Makeup	2026-04-02			540	\N
2216	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14B	H&S	Thu	CR-01-UG Block	01:00 PM	02:00 PM	Lec	Makeup	2026-04-02			780	\N
2217	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12A	H&S	Thu	Lec Hall-PG Block	01:00 PM	02:00 PM	Lec	Makeup	2026-04-02			780	\N
2218	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12B	H&S	Thu	Lec Hall-PG Block	01:00 PM	02:00 PM	Lec	Makeup	2026-04-02			780	\N
2219	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12C	H&S	Thu	Lec Hall-PG Block	01:00 PM	02:00 PM	Lec	Makeup	2026-04-02			780	\N
2220	Dr. Nosherwan Shoaib	Electrical Network Analysis	2K25-BEE-17C	ECE	Fri	CR-02-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-04-03			900	\N
2221	Dr. Nosherwan Shoaib	Electrical Network Analysis	2K25-BEE-17C	ECE	Fri	CR-02-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-03			960	\N
2222	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17A	H&S	Fri	CR-01-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-03			600	\N
2223	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15A	ECE	Fri	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-04-03			660	\N
2224	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Fri	CR-01-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-04-03			720	\N
2225	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Fri	CR-07-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-04-03			840	\N
2226	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16A	H&S	Fri	CR-02-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-04-03			840	\N
2227	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16B	H&S	Fri	CR-02-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-04-03			840	\N
2228	Dr. Hashir Moheed Kiyani	Machine Learning	2K23-BESE-14A	FoC	Fri	CR-17-IAEC	03:00 PM	04:00 PM	Lec	Makeup	2026-04-03			900	\N
2229	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Fri	Computing Lab-03	02:00 PM	03:00 PM	Lab	Makeup	2026-04-03			840	\N
2230	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Fri	Computing Lab-03	03:00 PM	04:00 PM	Lab	Makeup	2026-04-03			900	\N
2231	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Fri	Computing Lab-03	04:00 PM	05:00 PM	Lab	Makeup	2026-04-03			960	\N
2232	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16A	H&S	Fri	CR-16-IAEC	10:00 AM	11:00 AM	Lec	Makeup	2026-04-03			600	\N
2233	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16B	H&S	Fri	CR-16-IAEC	11:00 AM	12:00 PM	Lec	Makeup	2026-04-03			660	\N
2234	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Fri	CR-13-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-03	Elective		600	\N
2235	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Fri	CR-13-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-04-03	Elective		660	\N
2236	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Fri	CR-13-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-04-03	Elective		720	\N
2237	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Fri	CR-13-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-03	Elective		600	\N
2238	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Fri	CR-13-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-04-03	Elective		660	\N
2239	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Fri	CR-13-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-04-03	Elective		720	\N
2240	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Fri	CR-13-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-03	Elective		600	\N
2241	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Fri	CR-13-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-04-03	Elective		660	\N
2242	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Fri	CR-13-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-04-03	Elective		720	\N
2243	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Fri	CR-13-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-03	Elective		600	\N
2244	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Fri	CR-13-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-04-03	Elective		660	\N
2245	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Fri	CR-13-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-04-03	Elective		720	\N
2246	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Fri	CR-13-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-03	Elective		600	\N
2247	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Fri	CR-13-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-04-03	Elective		660	\N
2248	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Fri	CR-13-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-04-03	Elective		720	\N
2249	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Fri	CR-13-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-03	Elective		600	\N
2250	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Fri	CR-13-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-04-03	Elective		660	\N
2251	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Fri	CR-13-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-04-03	Elective		720	\N
2252	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Fri	CR-13-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-03	Elective		600	\N
2253	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Fri	CR-13-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-04-03	Elective		660	\N
2254	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Fri	CR-13-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-04-03	Elective		720	\N
2255	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Fri	CR-13-UG Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-03	Elective		600	\N
2256	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Fri	CR-13-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-04-03	Elective		660	\N
2257	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Fri	CR-13-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-04-03	Elective		720	\N
2258	Ms. Sadia Arshad	Functional English	2K25-BESE-16B	H&S	Fri	CR-15-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-04-03			900	\N
2259	Ms. Sadia Arshad	Functional English	2K25-BESE-16B	H&S	Fri	CR-15-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-03			960	\N
2260	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14B	FoC	Fri	CR-11-UG Block	12:00 PM	01:00 PM	Lec	Makeup	2026-04-03			720	\N
2261	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Fri	CR-03-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-03			960	\N
2262	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15B	H&S	Fri	Lec Hall-IAEC	02:00 PM	03:00 PM	Lec	Makeup	2026-04-03			840	\N
2263	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15B	H&S	Fri	Lec Hall-IAEC	03:00 PM	04:00 PM	Lec	Makeup	2026-04-03			900	\N
2264	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14A	H&S	Fri	CR-06-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-04-03			900	\N
2265	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16A	ECE	Fri	Lec Hall-PG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-04-03			900	\N
2266	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16A	ECE	Fri	Lec Hall-PG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-03			960	\N
2267	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Fri	Lec Hall-PG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-03			960	\N
2268	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Fri	Lec Hall-PG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-03			960	\N
2269	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Fri	CR-15-UG Block	11:00 AM	12:00 PM	Lec	Makeup	2026-04-03			660	\N
2270	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Mon	CR-26-Acad Block	09:00 AM	10:00 AM	Lec	Makeup	2026-04-06			540	\N
2271	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Mon	CR-26-Acad Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-06			600	\N
2272	Dr. Ibrar Hussain	Differential Equations	2K25-BEE-17C	H&S	Mon	CR-28-Acad Block	09:00 AM	10:00 AM	Lec	Makeup	2026-04-06			540	\N
2273	Dr. Ibrar Hussain	Differential Equations	2K25-BEE-17C	H&S	Mon	CR-28-Acad Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-06			600	\N
2274	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSAi-2A	ECE	Mon	CR-01-UG Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-06			960	\N
2275	Dr. Ibrar Hussain	Numerical Methods	2K23-BEE-15C	H&S	Tue	CR-20-IAEC	11:00 AM	12:00 PM	Lec	Makeup	2026-04-07			660	\N
2276	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-08			960	\N
2277	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Thu	CR-25-Acad Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-09			960	\N
2278	Dr. Ibrar Hussain	Numerical Methods	2K23-BEE-15C	H&S	Thu	Computing Lab-03	12:00 PM	01:00 PM	Lec	Makeup	2026-04-09			720	\N
2279	Ms. Sadia Arshad	Functional English	2K25-BESE-16B	H&S	Fri	CR-15-UG Block	02:00 PM	03:00 PM	Lec	Makeup	2026-04-10			840	\N
2280	Ms. Sadia Arshad	Functional English	2K25-BESE-16B	H&S	Fri	CR-15-UG Block	03:00 PM	04:00 PM	Lec	Makeup	2026-04-10			900	\N
2281	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Mon	CR-26-Acad Block	09:00 AM	10:00 AM	Lec	Makeup	2026-04-13			540	\N
2282	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Mon	CR-26-Acad Block	10:00 AM	11:00 AM	Lec	Makeup	2026-04-13			600	\N
2283	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-15			960	\N
2284	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Thu	CR-25-Acad Block	04:00 PM	05:00 PM	Lec	Makeup	2026-04-16			960	\N
2285	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Thu	CR-26-Acad Block	12:00 PM	01:00 PM	Lec	Makeup	2026-04-30			720	\N
2286	Dr. Aimal Tariq Rextin	Design & Analysis of Algorithm	2K24-BESE-15B	FoC	Tue	CR-17-IAEC	03:00 PM	04:00 PM	Lec	Missed	2026-03-17			900	\N
2287	Dr. Aimal Tariq Rextin	Design & Analysis of Algorithm	2K24-BESE-15B	FoC	Tue	CR-17-IAEC	04:00 PM	05:00 PM	Lec	Missed	2026-03-17			960	\N
2288	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15A	ECE	Tue	CR-19-IAEC	09:00 AM	10:00 AM	Lec	Missed	2026-03-17			540	\N
2289	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15A	ECE	Tue	CR-19-IAEC	10:00 AM	11:00 AM	Lec	Missed	2026-03-17			600	\N
2290	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15B	ECE	Tue	CR-20-IAEC	03:00 PM	04:00 PM	Lec	Missed	2026-03-17			900	\N
2291	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16A	H&S	Tue	CR-05-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-03-17			900	\N
2292	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16A	H&S	Tue	CR-05-UG Block	04:00 PM	05:00 PM	Lec	Missed	2026-03-17			960	\N
2293	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16B	H&S	Tue	CR-06-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-03-17			840	\N
2294	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Tue	CR-09-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-03-17			600	\N
2295	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Tue	CR-09-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-17			660	\N
2296	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Tue	CR-08-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-03-17			540	\N
2297	Dr. Rabia Irfan	Data Warehousing and Business Intelligence	2K23-BSDS-1A	FoC	Tue	CR-28-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-17			660	\N
2298	Dr. Rabia Irfan	Data Warehousing and Business Intelligence	2K23-BSDS-1A	FoC	Tue	CR-28-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-17			720	\N
2299	Dr. Samia Tahir	Expository Writing	2K24-BSAi-1A	H&S	Tue	CR-06-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-03-17			540	\N
2300	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16B	ECE	Tue	CR-06-UG Block	04:00 PM	05:00 PM	Lec	Missed	2026-03-17			960	\N
2301	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Tue	CR-08-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-03-17			840	\N
2302	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Tue	CR-08-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-03-17			900	\N
2303	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Tue	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-17			660	\N
2304	Mr. Taufique ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Tue	CR-16-IAEC	11:00 AM	12:00 PM	Lec	Missed	2026-03-17			660	\N
2305	Mr. Taufique ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Tue	CR-16-IAEC	12:00 PM	01:00 PM	Lec	Missed	2026-03-17			720	\N
2306	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14C	H&S	Tue	Physics Lab-1-SNS	10:00 AM	11:00 AM	Lab	Missed	2026-03-17			600	\N
2307	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14C	H&S	Tue	Physics Lab-1-SNS	11:00 AM	12:00 PM	Lab	Missed	2026-03-17			660	\N
2308	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14C	H&S	Tue	Physics Lab-1-SNS	12:00 PM	01:00 PM	Lab	Missed	2026-03-17			720	\N
2309	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14D	H&S	Tue	Physics Lab-1-SNS	02:00 PM	03:00 PM	Lab	Missed	2026-03-17			840	\N
2310	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14D	H&S	Tue	Physics Lab-1-SNS	03:00 PM	04:00 PM	Lab	Missed	2026-03-17			900	\N
2311	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14D	H&S	Tue	Physics Lab-1-SNS	04:00 PM	05:00 PM	Lab	Missed	2026-03-17			960	\N
2312	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14C	H&S	Tue	CR-04-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-03-17			540	\N
2313	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14C	H&S	Tue	CR-04-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-03-17			600	\N
2314	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSDS-3A	H&S	Wed	CR-01-UG Block	02:00 PM	03:00 PM	Lab	Missed	2026-03-25			840	\N
2315	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSDS-3A	H&S	Wed	CR-01-UG Block	03:00 PM	04:00 PM	Lab	Missed	2026-03-25			900	\N
2316	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSDS-3A	H&S	Wed	CR-01-UG Block	04:00 PM	05:00 PM	Lab	Missed	2026-03-25			960	\N
2317	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Wed	CR-02-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-25			660	\N
2318	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Wed	CR-03-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-03-25			540	\N
2319	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Wed	CR-03-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-03-25			600	\N
2320	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17A	H&S	Wed	CR-14-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-03-25			600	\N
2321	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17A	H&S	Wed	CR-14-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-25			660	\N
2322	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Wed	CR-18-IAEC	09:00 AM	10:00 AM	Lec	Missed	2026-03-25			540	\N
2323	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14A	FoC	Wed	CR-23-Acad Block	02:00 PM	03:00 PM	Lec	Missed	2026-03-25			840	\N
2324	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14A	FoC	Wed	CR-23-Acad Block	03:00 PM	04:00 PM	Lec	Missed	2026-03-25			900	\N
2325	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13C	ECE	Wed	CR-26-Acad Block	02:00 PM	03:00 PM	Lec	Missed	2026-03-25			840	\N
2326	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13C	ECE	Wed	CR-26-Acad Block	03:00 PM	04:00 PM	Lec	Missed	2026-03-25			900	\N
2327	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13A	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-25	Elective		660	\N
2328	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13A	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-25	Elective		720	\N
2329	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13B	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-25	Elective		660	\N
2330	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13B	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-25	Elective		720	\N
2331	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13C	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-25	Elective		660	\N
2332	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13C	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-25	Elective		720	\N
2333	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13D	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-25	Elective		660	\N
2334	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13D	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-25	Elective		720	\N
2335	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13E	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-25	Elective		660	\N
2336	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13E	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-25	Elective		720	\N
2337	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13D	FoC	Wed	CR-27-Acad Block	02:00 PM	03:00 PM	Lec	Missed	2026-03-25			840	\N
2338	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13D	FoC	Wed	CR-27-Acad Block	03:00 PM	04:00 PM	Lec	Missed	2026-03-25			900	\N
2339	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12A	FoC	Thu	CR-07-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-03-26			840	\N
2340	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12B	FoC	Thu	CR-07-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-03-26			900	\N
2341	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Thu	CR-08-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-03-26			900	\N
2342	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Thu	CR-09-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-03-26			840	\N
2343	Mr. Maajid Maqbool	Entrepreneurship	2K22-BEE-14B	FoC	Thu	CR-13-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-26			660	\N
2344	Mr. Maajid Maqbool	Entrepreneurship	2K22-BEE-14B	FoC	Thu	CR-13-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-26			720	\N
2345	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15C	H&S	Fri	CR-03-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-03-27			840	\N
2346	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15C	H&S	Fri	CR-03-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-03-27			900	\N
2347	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15B	H&S	Fri	CR-05-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-27			720	\N
2348	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16B	H&S	Mon	CR-06-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-03-30			900	\N
2349	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Mon	CR-08-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-30			720	\N
2350	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Mon	CR-12-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-03-30	Elective		540	\N
2351	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Mon	CR-12-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-03-30	Elective		600	\N
2352	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Mon	CR-12-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-03-30	Elective		540	\N
2353	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Mon	CR-12-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-03-30	Elective		600	\N
2354	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Mon	CR-12-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-03-30	Elective		540	\N
2355	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Mon	CR-12-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-03-30	Elective		600	\N
2356	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Mon	CR-12-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-03-30	Elective		540	\N
2357	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Mon	CR-12-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-03-30	Elective		600	\N
2358	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Mon	CR-12-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-30	Elective		720	\N
2359	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Mon	CR-12-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-30	Elective		720	\N
2360	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Mon	CR-12-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-30	Elective		720	\N
2361	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Mon	CR-12-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-30	Elective		720	\N
2362	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15A	H&S	Mon	CR-17-IAEC	10:00 AM	11:00 AM	Lec	Missed	2026-03-30			600	\N
2363	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15B	H&S	Mon	CR-17-IAEC	09:00 AM	10:00 AM	Lec	Missed	2026-03-30			540	\N
2364	Dr. Hina Munir Dutt	Differential Equations	2K25-BEE-17D	H&S	Mon	CR-15-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-03-30			840	\N
2365	Dr. Nosherwan Shoaib	Electrical Network Analysis	2K25-BEE-17C	ECE	Mon	CR-28-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-30			660	\N
2366	Dr. Nosherwan Shoaib	Electrical Network Analysis	2K25-BEE-17C	ECE	Mon	CR-28-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-30			720	\N
2367	Dr. Samia Tahir	Expository Writing	2K24-BSAi-1A	H&S	Tue	CR-06-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-03-31			540	\N
2368	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Tue	CR-08-UG Block	09:00 AM	10:00 AM	Lec	Missed	2026-03-31			540	\N
2369	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Tue	CR-09-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-03-31			600	\N
2370	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Tue	CR-09-UG Block	10:00 AM	11:00 AM	Lec	Missed	2026-03-31			600	\N
2371	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15A	H&S	Tue	CR-16-IAEC	10:00 AM	11:00 AM	Lec	Missed	2026-03-31			600	\N
2372	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15B	H&S	Tue	CR-17-IAEC	09:00 AM	10:00 AM	Lec	Missed	2026-03-31			540	\N
2373	Dr. Hina Munir Dutt	Differential Equations	2K25-BEE-17D	H&S	Tue	CR-09-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-31			720	\N
2374	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Tue	CR-09-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-03-31	Elective		840	\N
2375	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Tue	CR-09-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-03-31	Elective		840	\N
2376	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Tue	CR-09-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-03-31	Elective		840	\N
2377	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Tue	CR-09-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-03-31	Elective		840	\N
2378	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Tue	CR-12-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-31	Elective		660	\N
2379	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Tue	CR-12-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-31	Elective		720	\N
2380	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Tue	CR-12-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-31	Elective		660	\N
2381	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Tue	CR-12-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-31	Elective		720	\N
2382	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Tue	CR-12-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-31	Elective		660	\N
2383	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Tue	CR-12-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-31	Elective		720	\N
2384	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Tue	CR-12-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-03-31	Elective		660	\N
2385	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Tue	CR-12-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-03-31	Elective		720	\N
2386	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Tue	CR-19-IAEC	02:00 PM	03:00 PM	Lec	Missed	2026-03-31			840	\N
2387	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Tue	CR-19-IAEC	03:00 PM	04:00 PM	Lec	Missed	2026-03-31			900	\N
2388	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14A	FoC	Tue	CR-21-SMRIMMS	02:00 PM	03:00 PM	Lec	Missed	2026-03-31			840	\N
2389	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14A	FoC	Tue	CR-21-SMRIMMS	03:00 PM	04:00 PM	Lec	Missed	2026-03-31			900	\N
2390	Mr. Fazal e Haq	Digital Signal Processing	2k23-BEE-15D	ECE	Mon	DSP & Comm Lab	02:00 PM	03:00 PM	Lab	Missed	2026-03-30			840	\N
2391	Mr. Fazal e Haq	Digital Signal Processing	2k23-BEE-15D	ECE	Mon	DSP & Comm Lab	03:00 PM	04:00 PM	Lab	Missed	2026-03-30			900	\N
2392	Mr. Fazal e Haq	Digital Signal Processing	2k23-BEE-15D	ECE	Mon	DSP & Comm Lab	04:00 PM	05:00 PM	Lab	Missed	2026-03-30			960	\N
2393	Dr. Sidra Shafiq	Applied Physics	2k24-BSCS-14C	H&S	Tue	Physics Lab-1-SNS	10:00 AM	11:00 AM	Lab	Missed	2026-03-31			600	\N
2394	Dr. Sidra Shafiq	Applied Physics	2k24-BSCS-14C	H&S	Tue	Physics Lab-1-SNS	11:00 AM	12:00 PM	Lab	Missed	2026-03-31			660	\N
2395	Dr. Sidra Shafiq	Applied Physics	2k24-BSCS-14C	H&S	Tue	Physics Lab-1-SNS	12:00 PM	01:00 PM	Lab	Missed	2026-03-31			720	\N
2396	Dr. Sidra Shafiq	Applied Physics	2k24-BSCS-14D	H&S	Tue	Physics Lab-1-SNS	02:00 PM	03:00 PM	Lab	Missed	2026-03-31			840	\N
2397	Dr. Sidra Shafiq	Applied Physics	2k24-BSCS-14D	H&S	Tue	Physics Lab-1-SNS	03:00 PM	04:00 PM	Lab	Missed	2026-03-31			900	\N
2398	Dr. Sidra Shafiq	Applied Physics	2k24-BSCS-14D	H&S	Tue	Physics Lab-1-SNS	04:00 PM	05:00 PM	Lab	Missed	2026-03-31			960	\N
2399	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17A	H&S	Wed	CR-14-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-04-01			720	\N
2400	Dr. Hina Munir Dutt	Differential Equations	2K25-BEE-17D	H&S	Wed	CR-15-UG Block	12:00 PM	01:00 PM	Lec	Missed	2026-04-01			720	\N
2401	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15A	H&S	Wed	CR-16-IAEC	11:00 AM	12:00 PM	Lec	Missed	2026-04-01			660	\N
2402	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15B	H&S	Wed	CR-17-IAEC	10:00 AM	11:00 AM	Lec	Missed	2026-04-01			600	\N
2403	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Wed	CR-21-SMRIMMS	11:00 AM	12:00 PM	Lec	Missed	2026-04-01			660	\N
2404	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Wed	CR-21-SMRIMMS	12:00 PM	01:00 PM	Lec	Missed	2026-04-01			720	\N
2405	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Wed	CR-22-SMRIMMS	03:00 PM	04:00 PM	Lec	Missed	2026-04-01			900	\N
2406	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Wed	CR-22-SMRIMMS	04:00 PM	05:00 PM	Lec	Missed	2026-04-01			960	\N
2407	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14A	FoC	Wed	CR-23-Acad Block	09:00 AM	10:00 AM	Lec	Missed	2026-04-01			540	\N
2408	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14A	FoC	Wed	CR-23-Acad Block	10:00 AM	11:00 AM	Lec	Missed	2026-04-01			600	\N
2409	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14B	FoC	Wed	CR-24-Acad Block	02:00 PM	03:00 PM	Lec	Missed	2026-04-01			840	\N
2410	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-04-01	Elective		660	\N
2411	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-04-01	Elective		720	\N
2412	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13B	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-04-01	Elective		660	\N
2413	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13B	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-04-01	Elective		720	\N
2414	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13C	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-04-01	Elective		660	\N
2415	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13C	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-04-01	Elective		720	\N
2416	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13D	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-04-01	Elective		660	\N
2417	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13D	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-04-01	Elective		720	\N
2418	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13E	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-04-01	Elective		660	\N
2419	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13E	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-04-01	Elective		720	\N
2420	Dr. Imran Malik	Applied Physics	2k24-BSDS-2A	H&S	Wed	Physics Lab-1-SNS	10:00 AM	11:00 AM	Lab	Missed	2026-04-01			600	\N
2421	Dr. Imran Malik	Applied Physics	2k24-BSDS-2A	H&S	Wed	Physics Lab-1-SNS	11:00 AM	12:00 PM	Lab	Missed	2026-04-01			660	\N
2422	Dr. Imran Malik	Applied Physics	2k24-BSDS-2A	H&S	Wed	Physics Lab-1-SNS	12:00 PM	01:00 PM	Lab	Missed	2026-04-01			720	\N
2423	Dr. Sidra Shafiq	Applied Physics	2k24-BSAI-1A	H&S	Wed	Physics Lab-1-SNS	02:00 PM	03:00 PM	Lab	Missed	2026-04-01			840	\N
2424	Dr. Sidra Shafiq	Applied Physics	2k24-BSAI-1A	H&S	Wed	Physics Lab-1-SNS	03:00 PM	04:00 PM	Lab	Missed	2026-04-01			900	\N
2425	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Thu	CR-08-UG Block	03:00 PM	04:00 PM	Lec	Missed	2026-04-02			900	\N
2426	Dr. Sidra Shafiq	Applied Physics	2k24-BSAI-1A	H&S	Wed	Physics Lab-1-SNS	04:00 PM	05:00 PM	Lab	Missed	2026-04-01			960	\N
2427	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Thu	CR-09-UG Block	02:00 PM	03:00 PM	Lec	Missed	2026-04-02			840	\N
2428	Dr. Imran Malik	Applied Physics	2k24-BSCS-14A	H&S	Thu	Physics Lab-1-SNS	10:00 AM	11:00 AM	Lab	Missed	2026-04-02			600	\N
2429	Dr. Imran Malik	Applied Physics	2k24-BSCS-14A	H&S	Thu	Physics Lab-1-SNS	11:00 AM	12:00 PM	Lab	Missed	2026-04-02			660	\N
2430	Dr. Imran Malik	Applied Physics	2k24-BSCS-14A	H&S	Thu	Physics Lab-1-SNS	12:00 PM	01:00 PM	Lab	Missed	2026-04-02			720	\N
2431	Dr. Imran Malik	Applied Physics	2k24-BSCS-14B	H&S	Thu	Physics Lab-1-SNS	02:00 PM	03:00 PM	Lab	Missed	2026-04-02			840	\N
2432	Dr. Imran Malik	Applied Physics	2k24-BSCS-14B	H&S	Thu	Physics Lab-1-SNS	03:00 PM	04:00 PM	Lab	Missed	2026-04-02			900	\N
2433	Dr. Imran Malik	Applied Physics	2k24-BSCS-14B	H&S	Thu	Physics Lab-1-SNS	04:00 PM	05:00 PM	Lab	Missed	2026-04-02			960	\N
2434	Mr. Wajid Ali	Workshop Practice	2k25-BEE-17A	ECE	Thu	MRC Lab-01 (SMME)	10:00 AM	11:00 AM	Lab	Missed	2026-04-02			600	\N
2435	Mr. Wajid Ali	Workshop Practice	2k25-BEE-17A	ECE	Thu	MRC Lab-01 (SMME)	11:00 AM	12:00 PM	Lab	Missed	2026-04-02			660	\N
2436	Mr. Wajid Ali	Workshop Practice	2k25-BEE-17A	ECE	Thu	MRC Lab-01 (SMME)	12:00 PM	01:00 PM	Lab	Missed	2026-04-02			720	\N
2437	Mr. Wajid Ali	Workshop Practice	2k25-BEE-17D	ECE	Thu	MRC Lab-02 (SMME)	10:00 AM	11:00 AM	Lab	Missed	2026-04-02			600	\N
2438	Mr. Wajid Ali	Workshop Practice	2k25-BEE-17D	ECE	Thu	MRC Lab-02 (SMME)	11:00 AM	12:00 PM	Lab	Missed	2026-04-02			660	\N
2439	Mr. Wajid Ali	Workshop Practice	2k25-BEE-17D	ECE	Thu	MRC Lab-02 (SMME)	12:00 PM	01:00 PM	Lab	Missed	2026-04-02			720	\N
2440	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Mon	CR-15-UG Block	11:00 AM	12:00 PM	Lec	Missed	2026-04-06	Elective		660	\N
2441	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14A	FoC	Mon	CR-21-SMRIMMS	12:00 PM	01:00 PM	Lec	Missed	2026-04-06			720	\N
2442	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Mon	CR-21-SMRIMMS	09:00 AM	10:00 AM	Lec	Missed	2026-04-06			540	\N
2443	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Mon	CR-18-IAEC	11:00 AM	12:00 PM	Lec	Missed	2026-04-06			660	\N
2444	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13A	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-04-06	Elective		660	\N
2445	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13A	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-04-06	Elective		720	\N
2446	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13B	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-04-06	Elective		660	\N
2447	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13B	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-04-06	Elective		720	\N
2448	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13C	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-04-06	Elective		660	\N
2449	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13C	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-04-06	Elective		720	\N
2450	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13D	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-04-06	Elective		660	\N
2451	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13D	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-04-06	Elective		720	\N
2452	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13E	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	Missed	2026-04-06	Elective		660	\N
2453	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13E	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	Missed	2026-04-06	Elective		720	\N
2455	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14A	ECE	Mon	Computing Lab-07	09:00 AM	10:00 AM	Lab	\N	\N	Elective		540	4
2456	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Mon	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	4
2457	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14A	ECE	Mon	Computing Lab-07	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
2458	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Mon	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	4
2459	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14A	ECE	Mon	Computing Lab-07	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
2460	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14A	ECE	Mon	CR-10-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2461	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Mon	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2462	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14A	ECE	Mon	CR-17-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2463	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14A	ECE	Mon	CR-18-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2464	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14A	ECE	Mon	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2465	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14A	ECE	Mon	Computing Lab-07	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2466	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14A	ECE	Mon	Computing Lab-09	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2467	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Mon	Embedded Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2468	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14A	ECE	Mon	Computing Lab-07	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2469	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14A	ECE	Mon	Computing Lab-09	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2470	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Mon	Embedded Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2471	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14A	ECE	Mon	Computing Lab-07	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2472	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14A	ECE	Mon	Computing Lab-09	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2473	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Mon	Embedded Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2474	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14A	H&S	Thu	CR-13-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2475	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14A	H&S	Thu	CR-13-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2476	Dr. Wasif Tanveer	Community Service Learning	2K22-BEE-14A	ECE	Thu	SMRIMMS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2477	Dr. Wasif Tanveer	Community Service Learning	2K22-BEE-14A	ECE	Thu	SMRIMMS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2478	Dr. Wasif Tanveer	Community Service Learning	2K22-BEE-14A	ECE	Thu	SMRIMMS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	4
2479	Mr. Yaruq Nadeem	Entrepreneurship	2K22-BEE-14A	H&S	Tue	CR-11-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2480	Mr. Yaruq Nadeem	Entrepreneurship	2K22-BEE-14A	H&S	Tue	CR-11-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2481	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14A	ECE	Tue	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2482	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14A	ECE	Tue	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2485	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14A	ECE	Tue	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2486	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14A	ECE	Tue	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2487	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14A	ECE	Tue	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2488	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14A	H&S	Tue	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2489	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14A	ECE	Tue	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2490	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14A	ECE	Tue	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2491	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14A	H&S	Tue	CR-09-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	4
2492	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14A	ECE	Tue	CR-12-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	4
2493	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Tue	CR-01-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2494	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14A	ECE	Tue	CR-09-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2495	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14A	ECE	Tue	CR-11-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2496	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14A	ECE	Tue	CR-12-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2497	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Tue	CR-01-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2498	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14A	ECE	Tue	CR-09-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2499	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14A	ECE	Tue	CR-11-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2500	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14A	ECE	Tue	CR-12-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2501	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14A	ECE	Wed	CR-13-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	4
2502	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14A	ECE	Wed	CR-13-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2503	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14A	ECE	Mon	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2504	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14A	ECE	Wed	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2505	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14A	ECE	Wed	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2506	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14A	ECE	Wed	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2507	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14A	ECE	Wed	Computing Lab-03	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2508	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14A	ECE	Wed	Computing Lab-04	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2509	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14A	ECE	Wed	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2510	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14A	ECE	Wed	Computing Lab-03	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2511	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14A	ECE	Wed	Computing Lab-04	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2512	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14A	ECE	Wed	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2513	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14A	ECE	Wed	Computing Lab-03	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2514	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14A	ECE	Wed	Computing Lab-04	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2515	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14A	ECE	Wed	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2516	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14B	ECE	Mon	Computing Lab-07	09:00 AM	10:00 AM	Lab	\N	\N	Elective		540	4
2517	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Mon	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	4
2518	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14B	ECE	Mon	Computing Lab-07	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
2519	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Mon	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	4
2520	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14B	ECE	Mon	Computing Lab-07	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
2521	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14B	ECE	Mon	CR-10-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2522	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Mon	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2523	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14B	ECE	Mon	CR-17-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2524	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14B	ECE	Mon	CR-18-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2525	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14B	ECE	Mon	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2526	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14B	ECE	Mon	Computing Lab-07	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2527	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14B	ECE	Mon	Computing Lab-09	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2528	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Mon	Embedded Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2529	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14B	ECE	Mon	Computing Lab-07	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2530	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14B	ECE	Mon	Computing Lab-09	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2531	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Mon	Embedded Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2532	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14B	ECE	Mon	Computing Lab-07	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2533	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14B	ECE	Mon	Computing Lab-09	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2534	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Mon	Embedded Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2535	Mr. Maajid Maqbool	Entrepreneurship	2K22-BEE-14B	FoC	Thu	CR-13-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2536	Mr. Maajid Maqbool	Entrepreneurship	2K22-BEE-14B	FoC	Thu	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2537	Dr. Neelma Naz	Community Service Learning	2K22-BEE-14B	ECE	Thu	SMRIMMS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2538	Dr. Neelma Naz	Community Service Learning	2K22-BEE-14B	ECE	Thu	SMRIMMS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2539	Dr. Neelma Naz	Community Service Learning	2K22-BEE-14B	ECE	Thu	SMRIMMS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	4
2540	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14B	H&S	Tue	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2541	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14B	H&S	Tue	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2542	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14B	ECE	Tue	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2543	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14B	ECE	Tue	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2544	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Tue	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2545	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14B	ECE	Tue	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2546	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14B	ECE	Tue	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2547	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14B	ECE	Tue	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2548	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14B	ECE	Tue	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2549	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14B	H&S	Tue	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2550	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14B	ECE	Tue	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2551	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14B	ECE	Tue	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2552	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14B	H&S	Tue	CR-09-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	4
2553	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14B	ECE	Tue	CR-12-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	4
2554	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Tue	CR-01-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2555	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14B	ECE	Tue	CR-09-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2556	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14B	ECE	Tue	CR-11-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2557	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14B	ECE	Tue	CR-12-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2558	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Tue	CR-01-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2559	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14B	ECE	Tue	CR-09-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2560	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14B	ECE	Tue	CR-11-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2561	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14B	ECE	Tue	CR-12-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2562	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14B	ECE	Wed	CR-13-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	4
2563	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14B	ECE	Wed	CR-13-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2564	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14B	ECE	Wed	CR-05-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2565	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14B	ECE	Wed	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2566	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14B	ECE	Wed	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2567	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14B	ECE	Wed	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2568	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14B	ECE	Wed	Computing Lab-03	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2569	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14B	ECE	Wed	Computing Lab-04	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2570	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14B	ECE	Wed	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2571	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14B	ECE	Wed	Computing Lab-03	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2572	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14B	ECE	Wed	Computing Lab-04	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2573	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14B	ECE	Wed	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2574	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14B	ECE	Wed	Computing Lab-03	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2575	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14B	ECE	Wed	Computing Lab-04	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2576	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14B	ECE	Wed	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2577	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14C	ECE	Mon	Computing Lab-07	09:00 AM	10:00 AM	Lab	\N	\N	Elective		540	4
2578	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Mon	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	4
2579	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14C	ECE	Mon	Computing Lab-07	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
2580	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Mon	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	4
2581	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14C	ECE	Mon	Computing Lab-07	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
2582	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14C	ECE	Mon	CR-10-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2583	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Mon	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2584	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14C	ECE	Mon	CR-17-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2585	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14C	ECE	Mon	CR-18-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2586	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14C	ECE	Mon	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2587	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14C	ECE	Mon	Computing Lab-07	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2588	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14C	ECE	Mon	Computing Lab-09	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2589	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Mon	Embedded Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2590	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14C	ECE	Mon	Computing Lab-07	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2591	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14C	ECE	Mon	Computing Lab-09	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2592	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Mon	Embedded Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2593	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14C	ECE	Mon	Computing Lab-07	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2594	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14C	ECE	Mon	Computing Lab-09	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2595	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Mon	Embedded Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2596	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14C	H&S	Thu	CR-09-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2597	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14C	H&S	Thu	CR-09-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2598	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14C	H&S	Thu	CR-09-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2599	Dr. Arbab Latif	Community Service Learning	2K22-BEE-14C	ECE	Thu	SMRIMMS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2600	Dr. Arbab Latif	Community Service Learning	2K22-BEE-14C	ECE	Thu	SMRIMMS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2601	Dr. Arbab Latif	Community Service Learning	2K22-BEE-14C	ECE	Thu	SMRIMMS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	4
2602	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14C	ECE	Tue	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2603	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14C	ECE	Tue	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2604	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Tue	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2605	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14C	ECE	Tue	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2606	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14C	ECE	Tue	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2607	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14C	ECE	Tue	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2608	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14C	ECE	Tue	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2609	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14C	H&S	Tue	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2610	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14C	ECE	Tue	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2611	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14C	ECE	Tue	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2612	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14C	H&S	Tue	CR-09-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	4
2613	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14C	ECE	Tue	CR-12-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	4
2614	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Tue	CR-01-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2615	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14C	ECE	Tue	CR-09-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2616	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14C	ECE	Tue	CR-11-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2617	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14C	ECE	Tue	CR-12-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2618	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Tue	CR-01-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2619	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14C	ECE	Tue	CR-09-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2620	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14C	ECE	Tue	CR-11-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2621	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14C	ECE	Tue	CR-12-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2622	Mr. Waseem Ahmed	Professional Ethics	2K22-BEE-14C	H&S	Wed	CR-09-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2623	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14C	ECE	Wed	CR-13-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	4
2624	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14C	ECE	Wed	CR-13-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2625	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14C	ECE	Wed	CR-05-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2626	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14C	ECE	Wed	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2627	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14C	ECE	Wed	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2628	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14C	ECE	Wed	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2629	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14C	ECE	Wed	Computing Lab-03	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2630	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14C	ECE	Wed	Computing Lab-04	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2631	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14C	ECE	Wed	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2632	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14C	ECE	Wed	Computing Lab-03	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2633	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14C	ECE	Wed	Computing Lab-04	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2634	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14C	ECE	Wed	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2635	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14C	ECE	Wed	Computing Lab-03	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2636	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14C	ECE	Wed	Computing Lab-04	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2637	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14C	ECE	Wed	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2638	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14D	ECE	Mon	Computing Lab-07	09:00 AM	10:00 AM	Lab	\N	\N	Elective		540	4
2639	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Mon	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	4
2640	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14D	ECE	Mon	Computing Lab-07	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
2641	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Mon	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	4
2642	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14D	ECE	Mon	Computing Lab-07	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
2643	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14D	ECE	Mon	CR-10-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2644	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Mon	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2645	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14D	ECE	Mon	CR-17-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2646	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14D	ECE	Mon	CR-18-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2647	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14D	ECE	Mon	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2648	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14D	ECE	Mon	Computing Lab-07	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2649	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14D	ECE	Mon	Computing Lab-09	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2650	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Mon	Embedded Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2651	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14D	ECE	Mon	Computing Lab-07	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2652	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14D	ECE	Mon	Computing Lab-09	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2653	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Mon	Embedded Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2654	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14D	ECE	Mon	Computing Lab-07	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2655	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14D	ECE	Mon	Computing Lab-09	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2656	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Mon	Embedded Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2657	Dr. Ehsan ul Hassan	Professional Ethics	2K22-BEE-14D	H&S	Thu	CR-05-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2658	Dr. Ehsan ul Hassan	Professional Ethics	2K22-BEE-14D	H&S	Thu	CR-05-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2659	Dr. Javeria Ahmed	Community Service Learning	2K22-BEE-14D	ECE	Thu	SMRIMMS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2660	Dr. Javeria Ahmed	Community Service Learning	2K22-BEE-14D	ECE	Thu	SMRIMMS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2661	Dr. Javeria Ahmed	Community Service Learning	2K22-BEE-14D	ECE	Thu	SMRIMMS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	4
2662	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14D	H&S	Tue	CR-04-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2663	Mr. Tariq Mansoor	Entrepreneurship	2K22-BEE-14D	H&S	Tue	CR-04-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2664	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14D	ECE	Tue	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2665	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14D	ECE	Tue	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2666	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Tue	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2667	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14D	ECE	Tue	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2668	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14D	ECE	Tue	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2669	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14D	ECE	Tue	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2670	Dr. Syed Taha Ali	Selected Topics in Telecommunication	2K22-BEE-14D	ECE	Tue	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2671	Dr. Ehsan ul Hassan	Human Resource Management (Gp-02)	2K22-BEE-14D	H&S	Tue	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2672	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14D	ECE	Tue	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2673	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14D	ECE	Tue	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2674	Dr. Ehsan ul Hassan	Human Resource Management (Gp-01)	2K22-BEE-14D	H&S	Tue	CR-09-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	4
2675	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14D	ECE	Tue	CR-12-UG Block	02:00 PM	03:00 PM	Lec	\N	\N	Elective		840	4
2676	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Tue	CR-01-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2677	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14D	ECE	Tue	CR-09-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2678	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14D	ECE	Tue	CR-11-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2679	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14D	ECE	Tue	CR-12-UG Block	03:00 PM	04:00 PM	Lec	\N	\N	Elective		900	4
2680	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Tue	CR-01-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2681	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14D	ECE	Tue	CR-09-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2682	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14D	ECE	Tue	CR-11-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2683	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14D	ECE	Tue	CR-12-UG Block	04:00 PM	05:00 PM	Lec	\N	\N	Elective		960	4
2684	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14D	ECE	Wed	CR-13-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	4
2685	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-01)	2K22-BEE-14D	ECE	Wed	CR-13-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2686	Dr. Tassawar Kazmi	Power Systems Protection	2K22-BEE-14D	ECE	Wed	CR-05-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2687	Syed Jawad Hussain Shah	Digital Design Verification	2K22-BEE-14D	ECE	Wed	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2688	Dr. Attique Dawood	Parallel & Distributed Computing	2K22-BEE-14D	ECE	Wed	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2689	Mr. Munadi Ahmad Sial	Robotics-1 (Gp-02)	2K22-BEE-14D	ECE	Wed	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2690	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14D	ECE	Wed	Computing Lab-03	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2691	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14D	ECE	Wed	Computing Lab-04	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2692	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14D	ECE	Wed	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2693	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14D	ECE	Wed	Computing Lab-03	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2694	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14D	ECE	Wed	Computing Lab-04	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2695	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14D	ECE	Wed	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2696	Dr. Sajjad Hussain	Deep Learning (Gp-01)	2K22-BEE-14D	ECE	Wed	Computing Lab-03	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2697	Ms. Asra Abid	Deep Learning (Gp-02)	2K22-BEE-14D	ECE	Wed	Computing Lab-04	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2698	Mr. Munadi Ahmad Sial	Data Structures and Algorithms	2K22-BEE-14D	ECE	Wed	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2699	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Mon	CR-15-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	4
2700	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Mon	CR-15-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	4
2701	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Mon	CR-15-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2702	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Mon	Computing Lab-01	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2703	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Mon	Computing Lab-01	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2704	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Mon	Computing Lab-01	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2705	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13A	FoC	Thu	CR-08-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	4
2706	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13A	FoC	Thu	CR-08-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	4
2707	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Thu	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2708	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13A	FoC	Thu	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2709	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2710	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2711	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Thu	Computing Lab-01	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2712	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13A	FoC	Tue	CR-05-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	4
2713	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13A	FoC	Tue	Computing Lab-02	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
2714	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13A	FoC	Tue	Computing Lab-02	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
2715	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13A	FoC	Tue	Computing Lab-02	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	4
2716	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13A	FoC	Tue	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2717	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13A	FoC	Tue	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2718	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13A	FoC	Tue	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2719	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13A	FoC	Wed	CR-04-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	4
2720	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13A	FoC	Wed	CR-04-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	4
2721	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13A	FoC	Wed	CR-04-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2722	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13A	FoC	Wed	CR-04-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2723	Dr. Muhammad Bilal Ali	Community Service Learning	2K22-BESE-13A	FoC	Wed	SEECS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2724	Dr. Muhammad Bilal Ali	Community Service Learning	2K22-BESE-13A	FoC	Wed	SEECS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2725	Dr. Muhammad Bilal Ali	Community Service Learning	2K22-BESE-13A	FoC	Wed	SEECS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	4
2726	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Mon	CR-15-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	4
2727	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Mon	CR-15-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	4
2728	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Mon	CR-15-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2729	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Mon	Computing Lab-01	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2730	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Mon	Computing Lab-01	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2731	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Mon	Computing Lab-01	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2732	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13B	FoC	Thu	CR-08-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	4
2733	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13B	FoC	Thu	CR-08-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	4
2734	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Thu	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2735	Dr. Sana Qadir	Computer Forensics	2K22-BESE-13B	FoC	Thu	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2736	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2737	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2738	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Thu	Computing Lab-01	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2739	Ms. Naema Asif	Mobile Application Development	2K22-BESE-13B	FoC	Tue	CR-05-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	4
2740	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13B	FoC	Tue	Computing Lab-02	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
2741	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13B	FoC	Tue	Computing Lab-02	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
2742	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13B	FoC	Tue	Computing Lab-02	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	4
2743	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13B	FoC	Tue	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2744	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13B	FoC	Tue	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2745	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13B	FoC	Tue	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2746	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13B	FoC	Wed	CR-04-UG Block	09:00 AM	10:00 AM	Lec	\N	\N	Elective		540	4
2747	Dr. Faisal Shafait	Large Language Models (Gp-01)	2K22-BESE-13B	FoC	Wed	CR-04-UG Block	10:00 AM	11:00 AM	Lec	\N	\N	Elective		600	4
2748	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13B	FoC	Wed	CR-04-UG Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2749	Dr. Momina Moetesum	Large Language Models (Gp-02)	2K22-BESE-13B	FoC	Wed	CR-04-UG Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2750	Dr. Muhammad Ashraf	Community Service Learning	2K22-BESE-13B	FoC	Wed	SEECS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2751	Dr. Muhammad Ashraf	Community Service Learning	2K22-BESE-13B	FoC	Wed	SEECS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2752	Dr. Muhammad Ashraf	Community Service Learning	2K22-BESE-13B	FoC	Wed	SEECS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	4
2753	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12A	FoC	Fri	CR-07-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2754	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12A	H&S	Fri	CR-07-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2755	Syeda Rabia Shaheen	Principles of Sociology	2K22-BSCS-12A	H&S	Fri	CR-07-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2756	Syeda Rabia Shaheen	Principles of Sociology	2K22-BSCS-12A	H&S	Thu	Lecture Hall-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2757	Syeda Rabia Shaheen	Principles of Sociology	2K22-BSCS-12A	H&S	Thu	Lecture Hall-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2758	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12A	H&S	Thu	Lecture Hall-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2759	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12A	FoC	Thu	CR-07-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2760	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12A	FoC	Wed	CR-07-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2761	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12A	H&S	Wed	CR-07-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2762	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12A	FoC	Wed	SEECS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2763	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12A	FoC	Wed	SEECS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2764	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12A	FoC	Wed	SEECS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	4
2765	Syeda Rabia Shaheen	Principles of Sociology	2K22-BSCS-12B	H&S	Fri	Lecture Hall-PG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2766	Syeda Rabia Shaheen	Principles of Sociology	2K22-BSCS-12B	H&S	Fri	Lecture Hall-PG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2767	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12B	FoC	Fri	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2768	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12B	H&S	Fri	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2769	Syeda Rabia Shaheen	Principles of Sociology	2K22-BSCS-12B	H&S	Thu	CR-18-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2770	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12B	H&S	Thu	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2771	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12B	FoC	Thu	CR-07-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2772	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12B	FoC	Wed	CR-06-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2773	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12B	H&S	Wed	CR-06-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2774	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12B	FoC	Wed	SEECS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2775	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12B	FoC	Wed	SEECS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2776	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12B	FoC	Wed	SEECS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	4
2777	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12C	H&S	Fri	CR-08-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2778	Dr. Tahira Anwar Lashari	Principles of Sociology	2K22-BSCS-12C	FoC	Fri	CR-08-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2779	Dr. Tahira Anwar Lashari	Principles of Sociology	2K22-BSCS-12C	FoC	Fri	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2780	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12C	FoC	Fri	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2781	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12C	H&S	Thu	CR-12-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2782	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12C	FoC	Thu	CR-12-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
2783	Dr. Muhammad Yousaf	Engineering Economics	2K22-BSCS-12C	H&S	Wed	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2784	Dr. Tahira Anwar Lashari	Principles of Sociology	2K22-BSCS-12C	FoC	Wed	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2785	Dr. Adnan Rashid	Compiler Construction	2K22-BSCS-12C	FoC	Wed	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2786	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12C	FoC	Wed	SEECS Seminar Hall	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2787	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12C	FoC	Wed	SEECS Seminar Hall	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2788	Mr. Taufiq ur Rehman	Community Service Learning	2K22-BSCS-12C	FoC	Wed	SEECS Seminar Hall	04:00 PM	05:00 PM	Lec	\N	\N			960	4
2789	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Fri	CR-19-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2790	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15A	ECE	Fri	DSP & Comm Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
2791	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15A	ECE	Fri	DSP & Comm Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
2792	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15A	ECE	Fri	DSP & Comm Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
2793	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Mon	CR-19-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2794	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15A	H&S	Mon	CR-19-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2795	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15A	ECE	Mon	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2796	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15A	ECE	Mon	CR-20-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2797	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15A	ECE	Mon	Lecture Hall-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2798	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15A	ECE	Mon	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2799	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15A	ECE	Mon	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2800	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15A	ECE	Mon	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2801	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15A	ECE	Thu	CR-19-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2802	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15A	H&S	Thu	CR-19-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2803	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Thu	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2804	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Thu	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2805	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Thu	Control System Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
2806	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Thu	Control System Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
2807	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Thu	Control System Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
2808	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15A	ECE	Tue	CR-19-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2809	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15A	ECE	Tue	CR-19-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2810	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Tue	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2811	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15A	ECE	Tue	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2812	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15A	ECE	Tue	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2813	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15A	ECE	Tue	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2814	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Tue	DSP & Comm Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
2815	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Tue	DSP & Comm Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
2816	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15A	ECE	Tue	DSP & Comm Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
2817	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15A	ECE	Wed	CR-19-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2818	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15A	H&S	Wed	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2819	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15A	ECE	Wed	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2820	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15A	ECE	Wed	EMS Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2821	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15A	ECE	Wed	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2822	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15A	ECE	Wed	EMS Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2823	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15A	ECE	Wed	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2824	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15A	ECE	Wed	EMS Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2825	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Fri	CR-20-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2826	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15B	ECE	Fri	DSP & Comm Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
2827	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15B	ECE	Fri	DSP & Comm Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
2828	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15B	ECE	Fri	DSP & Comm Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
2829	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15B	H&S	Mon	CR-20-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2830	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Mon	CR-20-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2831	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15B	ECE	Mon	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2832	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15B	ECE	Mon	CR-20-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2833	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15B	ECE	Mon	Lecture Hall-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2834	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15B	ECE	Mon	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2835	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15B	ECE	Mon	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2836	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15B	ECE	Mon	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2837	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Thu	Control System Lab	09:00 AM	10:00 AM	Lab	\N	\N			540	4
2838	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Thu	Control System Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
2839	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Thu	Control System Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
2840	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15B	H&S	Thu	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2841	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15B	ECE	Thu	CR-20-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2842	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15B	ECE	Thu	CR-20-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2843	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Tue	DSP & Comm Lab	09:00 AM	10:00 AM	Lab	\N	\N			540	4
2844	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Tue	DSP & Comm Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
2845	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Tue	DSP & Comm Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
2846	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15B	ECE	Tue	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2847	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15B	ECE	Tue	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2848	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15B	ECE	Tue	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2849	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Tue	CR-20-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2850	Dr. Huma Ghafoor	Communication Systems	2K23-BEE-15B	ECE	Tue	CR-20-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2851	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Wed	CR-20-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2852	Dr. Tauseef ur Rehman	Digital Signal Processing	2K23-BEE-15B	ECE	Wed	CR-20-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2853	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15B	ECE	Wed	CR-20-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2854	Mr. Saeed Afzal	Numerical Methods	2K23-BEE-15B	H&S	Wed	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2855	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15B	ECE	Wed	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2856	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15B	ECE	Wed	EMS Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2857	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15B	ECE	Wed	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2858	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15B	ECE	Wed	EMS Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2859	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15B	ECE	Wed	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2860	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15B	ECE	Wed	EMS Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2861	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Fri	CR-19-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2862	Dr. Ibrar Hussain	Numerical Methods	2K23-BEE-15C	H&S	Fri	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2863	Dr. Sajjad Hussain	Communication Systems	2K23-BEE-15C	ECE	Mon	CR-16-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2864	Dr. Sajjad Hussain	Communication Systems	2K23-BEE-15C	ECE	Mon	CR-16-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2865	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15C	ECE	Mon	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2866	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15C	ECE	Mon	CR-20-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2867	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15C	ECE	Mon	Lecture Hall-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2868	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15C	ECE	Mon	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2869	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15C	ECE	Mon	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2870	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15C	ECE	Mon	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2871	Dr. Nauman Anwar Baig	Digital Signal Processing	2K23-BEE-15C	ECE	Mon	CR-19-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2872	Dr. Nauman Anwar Baig	Digital Signal Processing	2K23-BEE-15C	ECE	Mon	CR-19-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2873	Dr. Nauman Anwar Baig	Digital Signal Processing	2K23-BEE-15C	ECE	Thu	CR-20-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2874	Dr. Ibrar Hussain	Numerical Methods	2K23-BEE-15C	H&S	Thu	CR-20-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2875	Dr. Ibrar Hussain	Numerical Methods	2K23-BEE-15C	H&S	Thu	CR-20-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2876	Dr. Sajjad Hussain	Communication Systems	2K23-BEE-15C	ECE	Thu	DSP & Comm Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
2877	Dr. Sajjad Hussain	Communication Systems	2K23-BEE-15C	ECE	Thu	DSP & Comm Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
2878	Dr. Sajjad Hussain	Communication Systems	2K23-BEE-15C	ECE	Thu	DSP & Comm Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
2879	Dr. Sajjad Hussain	Communication Systems	2K23-BEE-15C	ECE	Tue	CR-20-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2880	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Tue	CR-20-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2881	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15C	ECE	Tue	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2882	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15C	ECE	Tue	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2883	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15C	ECE	Tue	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2884	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Tue	Control System Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
2885	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Tue	Control System Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
2886	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Tue	Control System Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
2887	Dr. Farid Gul	Linear Control Systems	2K23-BEE-15C	ECE	Wed	CR-19-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2888	Dr. Nauman Anwar Baig	Digital Signal Processing	2K23-BEE-15C	ECE	Wed	DSP & Comm Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
2889	Dr. Nauman Anwar Baig	Digital Signal Processing	2K23-BEE-15C	ECE	Wed	DSP & Comm Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
2890	Dr. Nauman Anwar Baig	Digital Signal Processing	2K23-BEE-15C	ECE	Wed	DSP & Comm Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
2891	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15C	ECE	Wed	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2892	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15C	ECE	Wed	EMS Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2893	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15C	ECE	Wed	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2894	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15C	ECE	Wed	EMS Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2895	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15C	ECE	Wed	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2896	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15C	ECE	Wed	EMS Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2897	Dr. Azad Akhtar Siddiqui	Numerical Methods	2K23-BEE-15D	H&S	Fri	CR-18-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2898	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Fri	CR-18-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2899	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Fri	CR-18-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2900	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Fri	CR-18-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2901	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Mon	Lecture Hall-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2902	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15D	ECE	Mon	CR-19-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2903	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15D	ECE	Mon	CR-20-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2904	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15D	ECE	Mon	Lecture Hall-IAEC	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2905	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15D	ECE	Mon	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2906	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15D	ECE	Mon	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2907	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15D	ECE	Mon	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2908	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Mon	DSP & Comm Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
2909	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Mon	DSP & Comm Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
2910	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Mon	DSP & Comm Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
2911	Dr. Azad Akhtar Siddiqui	Numerical Methods	2K23-BEE-15D	H&S	Thu	CR-18-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2912	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Thu	DSP & Comm Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
2913	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Thu	DSP & Comm Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
2914	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Thu	DSP & Comm Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
2915	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Tue	Control System Lab	09:00 AM	10:00 AM	Lab	\N	\N			540	4
2916	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Tue	Control System Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
2917	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Tue	Control System Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
2918	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15D	ECE	Tue	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2919	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15D	ECE	Tue	CR-20-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2920	Dr. Muhammad Imran	Digital System Design (Gp-01 & Gp-02)	2K23-BEE-15D	ECE	Tue	Lecture Hall-IAEC	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2921	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Tue	CR-18-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2922	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Tue	CR-18-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2923	Dr. Neelma Naz	Linear Control Systems	2K23-BEE-15D	ECE	Wed	CR-18-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2924	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Wed	CR-18-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2925	Dr. Rizwan Ahmad	Communication Systems	2K23-BEE-15D	ECE	Wed	CR-18-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2926	Dr. Azad Akhtar Siddiqui	Numerical Methods	2K23-BEE-15D	H&S	Wed	CR-18-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2927	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15D	ECE	Wed	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2928	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15D	ECE	Wed	EMS Lab	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2929	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15D	ECE	Wed	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2930	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15D	ECE	Wed	EMS Lab	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2931	Dr. Hassaan Khaliq	Computer and Communication Networks	2K23-BEE-15D	ECE	Wed	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2932	Dr. Wajid Mumtaz	Power Electronics	2K23-BEE-15D	ECE	Wed	EMS Lab	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2933	Dr. Hasan Tahir Butt	Human Computer Interaction	2K23-BESE-14A	FoC	Fri	Computing Lab-11	09:00 AM	10:00 AM	Lab	\N	\N			540	4
2934	Dr. Hasan Tahir Butt	Human Computer Interaction	2K23-BESE-14A	FoC	Fri	Computing Lab-11	10:00 AM	11:00 AM	Lab	\N	\N			600	4
2935	Dr. Hasan Tahir Butt	Human Computer Interaction	2K23-BESE-14A	FoC	Fri	Computing Lab-11	11:00 AM	12:00 PM	Lab	\N	\N			660	4
2936	Ms. Ayesha Kanwal	Software Project Management	2K23-BESE-14A	FoC	Fri	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2937	Dr. Hashir Moheed Kiyani	Machine Learning	2K23-BESE-14A	FoC	Mon	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N			600	4
2938	Dr. Hashir Moheed Kiyani	Machine Learning	2K23-BESE-14A	FoC	Mon	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N			660	4
2939	Dr. Hashir Moheed Kiyani	Machine Learning	2K23-BESE-14A	FoC	Mon	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N			720	4
2940	Ms. Ayesha Kanwal	Software Project Management	2K23-BESE-14A	FoC	Mon	CR-05-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2941	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14A	FoC	Thu	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2942	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14A	FoC	Thu	CR-23-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2943	Dr. Hashir Moheed Kiyani	Machine Learning	2K23-BESE-14A	FoC	Thu	CR-23-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2944	Dr. Hashir Moheed Kiyani	Machine Learning	2K23-BESE-14A	FoC	Thu	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2945	Ms. Ayesha Kanwal	Software Project Management	2K23-BESE-14A	FoC	Tue	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2946	Mr. Maajid Maqbool	Entrepreneurship	2K23-BESE-14A	FoC	Tue	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2947	Dr. Hasan Tahir Butt	Human Computer Interaction	2K23-BESE-14A	FoC	Tue	CR-23-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2948	Dr. Hasan Tahir Butt	Human Computer Interaction	2K23-BESE-14A	FoC	Tue	CR-23-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2949	Dr. Hashir Moheed Kiyani	Machine Learning	2K23-BESE-14A	FoC	Tue	CR-23-Acad Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
2950	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14A	FoC	Wed	CR-23-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2951	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14A	FoC	Wed	CR-23-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2952	Mr. Maajid Maqbool	Entrepreneurship	2K23-BESE-14A	FoC	Wed	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2953	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14A	FoC	Wed	CR-23-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2954	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14A	FoC	Wed	CR-23-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2955	Ms. Ayesha Kanwal	Software Project Management	2K23-BESE-14B	FoC	Fri	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2956	Mr. Hamza Saleem	Human Computer Interaction	2K23-BESE-14B	FoC	Fri	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N			840	4
2957	Mr. Hamza Saleem	Human Computer Interaction	2K23-BESE-14B	FoC	Fri	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N			900	4
2958	Mr. Hamza Saleem	Human Computer Interaction	2K23-BESE-14B	FoC	Fri	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N			960	4
2959	Ms. Ayesha Kanwal	Software Project Management	2K23-BESE-14B	FoC	Mon	CR-24-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2960	Dr. Muhammad Daud Abdullah Asif	Machine Learning	2K23-BESE-14B	FoC	Mon	CR-24-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2961	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14B	FoC	Mon	CR-24-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2962	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14B	FoC	Mon	CR-24-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2963	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14B	FoC	Thu	CR-24-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2964	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14B	FoC	Thu	CR-24-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2965	Ms. Hareem Ashraf	Software Project Management	2K23-BESE-14B	FoC	Thu	CR-24-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2966	Mr. Hamza Saleem	Human Computer Interaction	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2967	Mr. Hamza Saleem	Human Computer Interaction	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2968	Mr. Maajid Maqbool	Entrepreneurship	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
2969	Ms. Ayesha Kanwal	Software Project Management	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2970	Dr. Muhammad Daud Abdullah Asif	Machine Learning	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2971	Dr. Muhammad Daud Abdullah Asif	Machine Learning	2K23-BESE-14B	FoC	Tue	CR-24-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
2972	Dr. Muhammad Daud Abdullah Asif	Machine Learning	2K23-BESE-14B	FoC	Wed	Computing Lab-10	09:00 AM	10:00 AM	Lab	\N	\N			540	4
2973	Dr. Muhammad Daud Abdullah Asif	Machine Learning	2K23-BESE-14B	FoC	Wed	Computing Lab-10	10:00 AM	11:00 AM	Lab	\N	\N			600	4
2974	Dr. Muhammad Daud Abdullah Asif	Machine Learning	2K23-BESE-14B	FoC	Wed	Computing Lab-10	11:00 AM	12:00 PM	Lab	\N	\N			660	4
2975	Mr. Maajid Maqbool	Entrepreneurship	2K23-BESE-14B	FoC	Wed	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2976	Ms. Sobia Ashraf	Formal Methods	2K23-BESE-14B	FoC	Wed	CR-24-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2977	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Fri	Computing Lab-10	09:00 AM	10:00 AM	Lab	\N	\N			540	4
2978	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Fri	Computing Lab-10	10:00 AM	11:00 AM	Lab	\N	\N			600	4
2979	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Fri	Computing Lab-10	11:00 AM	12:00 PM	Lab	\N	\N			660	4
2980	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13A	FoC	Fri	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
2981	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13A	FoC	Fri	Computing Lab-01	02:00 PM	03:00 PM	Lab	\N	\N			840	4
2982	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13A	FoC	Fri	Computing Lab-01	03:00 PM	04:00 PM	Lab	\N	\N			900	4
2983	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13A	FoC	Fri	Computing Lab-01	04:00 PM	05:00 PM	Lab	\N	\N			960	4
2984	Dr. Junaid Younas	Deep Learning	2K23-BSCS-13A	FoC	Mon	CR-25-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
2985	Dr. Junaid Younas	Deep Learning	2K23-BSCS-13A	FoC	Mon	CR-25-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
2986	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13A	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2987	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13A	FoC	Mon	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2988	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13A	FoC	Mon	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
2989	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13A	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2990	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13A	FoC	Mon	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2991	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13A	FoC	Mon	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
2992	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13A	FoC	Mon	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
2993	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13A	FoC	Mon	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
2994	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13A	FoC	Mon	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
2995	Dr. Junaid Younas	Deep Learning	2K23-BSCS-13A	FoC	Thu	Computing Lab-02	10:00 AM	11:00 AM	Lab	\N	\N			600	4
2996	Dr. Junaid Younas	Deep Learning	2K23-BSCS-13A	FoC	Thu	Computing Lab-02	11:00 AM	12:00 PM	Lab	\N	\N			660	4
2997	Dr. Junaid Younas	Deep Learning	2K23-BSCS-13A	FoC	Thu	Computing Lab-02	12:00 PM	01:00 PM	Lab	\N	\N			720	4
2998	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13A	FoC	Thu	CR-25-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
2999	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13A	FoC	Thu	CR-25-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3000	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13A	FoC	Tue	Computing Lab-11	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
3001	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13A	FoC	Tue	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
3002	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13A	FoC	Tue	Computing Lab-11	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
3003	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13A	FoC	Tue	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
3004	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13A	FoC	Tue	Computing Lab-11	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	4
3005	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13A	FoC	Tue	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	4
3006	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13A	FoC	Tue	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
3007	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13A	FoC	Tue	Computing Lab-12	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
3008	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13A	FoC	Tue	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
3009	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13A	FoC	Tue	Computing Lab-12	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
3010	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13A	FoC	Tue	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
3011	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13A	FoC	Tue	Computing Lab-12	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
3012	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3013	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3014	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3015	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13A	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3016	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3017	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13A	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3018	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3019	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13A	FoC	Wed	CR-25-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3020	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13B	FoC	Fri	CR-25-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3021	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13B	FoC	Fri	Computing Lab-01	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3022	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13B	FoC	Fri	Computing Lab-01	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3023	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13B	FoC	Fri	Computing Lab-01	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3024	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Fri	Computing Lab-10	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3025	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Fri	Computing Lab-10	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3026	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Fri	Computing Lab-10	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3027	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13B	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3028	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13B	FoC	Mon	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3029	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13B	FoC	Mon	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3030	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13B	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3031	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13B	FoC	Mon	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3032	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13B	FoC	Mon	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3033	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13B	FoC	Mon	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
3034	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13B	FoC	Mon	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
3035	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13B	FoC	Mon	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
3036	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13B	FoC	Thu	CR-25-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3037	Dr. Gibrail Islam	Software Engineering	2K23-BSCS-13B	FoC	Thu	CR-25-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3038	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13B	FoC	Thu	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3039	Dr. Muhammad Khuram Shahzad	Parallel & Distributed Computing	2K23-BSCS-13B	FoC	Thu	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3040	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Thu	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3041	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Thu	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3042	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Thu	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3043	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13B	FoC	Tue	Computing Lab-11	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
3044	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13B	FoC	Tue	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
3045	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13B	FoC	Tue	Computing Lab-11	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
3046	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13B	FoC	Tue	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
3047	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13B	FoC	Tue	Computing Lab-11	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	4
3048	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13B	FoC	Tue	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	4
3049	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13B	FoC	Tue	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
3050	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13B	FoC	Tue	Computing Lab-12	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
3051	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13B	FoC	Tue	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
3052	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13B	FoC	Tue	Computing Lab-12	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
3053	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13B	FoC	Tue	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
3054	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13B	FoC	Tue	Computing Lab-12	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
3055	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Wed	CR-24-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3056	Dr. Muhammad Ahmad Rathore	Compiler Construction	2K23-BSCS-13B	FoC	Wed	CR-24-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3057	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13B	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3058	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13B	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3059	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13B	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3060	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13B	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3061	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Wed	CR-05-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3062	Dr. Muhammad Imran Malik	Deep Learning	2K23-BSCS-13B	FoC	Wed	CR-05-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3063	Dr. Shah Khalid	Parallel & Distributed Computing	2K23-BSCS-13C	FoC	Fri	CR-26-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3064	Dr. Shah Khalid	Parallel & Distributed Computing	2K23-BSCS-13C	FoC	Fri	CR-26-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3065	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13C	FoC	Fri	CR-26-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3066	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13C	FoC	Fri	CR-26-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3067	Dr. Mehwish Awan	Deep Learning	2K23-BSCS-13C	FoC	Fri	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3068	Dr. Mehwish Awan	Deep Learning	2K23-BSCS-13C	FoC	Fri	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3069	Dr. Mehwish Awan	Deep Learning	2K23-BSCS-13C	FoC	Fri	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3070	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13C	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3071	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13C	FoC	Mon	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3072	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13C	FoC	Mon	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3073	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13C	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3074	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13C	FoC	Mon	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3075	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13C	FoC	Mon	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3076	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13C	FoC	Mon	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
3077	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13C	FoC	Mon	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
3078	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13C	FoC	Mon	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
3079	Dr. Shah Khalid	Parallel & Distributed Computing	2K23-BSCS-13C	FoC	Thu	Computing Lab-07	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3080	Dr. Shah Khalid	Parallel & Distributed Computing	2K23-BSCS-13C	FoC	Thu	Computing Lab-07	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3081	Dr. Shah Khalid	Parallel & Distributed Computing	2K23-BSCS-13C	FoC	Thu	Computing Lab-07	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3082	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13C	FoC	Thu	CR-26-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3083	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13C	ECE	Thu	Computing Lab-10	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3084	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13C	ECE	Thu	Computing Lab-10	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3085	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13C	ECE	Thu	Computing Lab-10	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3086	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13C	FoC	Tue	Computing Lab-11	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
3087	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13C	FoC	Tue	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
3088	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13C	FoC	Tue	Computing Lab-11	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
3089	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13C	FoC	Tue	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
3090	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13C	FoC	Tue	Computing Lab-11	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	4
3091	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13C	FoC	Tue	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	4
3092	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13C	FoC	Tue	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
3093	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13C	FoC	Tue	Computing Lab-12	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
3094	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13C	FoC	Tue	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
3095	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13C	FoC	Tue	Computing Lab-12	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
3096	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13C	FoC	Tue	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
3097	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13C	FoC	Tue	Computing Lab-12	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
3098	Dr. Mehwish Awan	Deep Learning	2K23-BSCS-13C	FoC	Wed	CR-28-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3099	Dr. Mehwish Awan	Deep Learning	2K23-BSCS-13C	FoC	Wed	CR-28-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3100	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13C	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3101	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13C	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3102	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13C	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3103	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13C	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3104	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13C	ECE	Wed	CR-26-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3105	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13C	ECE	Wed	CR-26-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3106	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13D	FoC	Fri	CR-23-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3107	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13D	FoC	Fri	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3108	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13D	FoC	Fri	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3109	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13D	FoC	Fri	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3110	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13D	ECE	Fri	CR-26-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3111	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13D	ECE	Fri	CR-26-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3112	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13D	FoC	Mon	CR-23-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3113	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13D	FoC	Mon	CR-23-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3114	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13D	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3115	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13D	FoC	Mon	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3116	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13D	FoC	Mon	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3117	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13D	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3118	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13D	FoC	Mon	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3119	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13D	FoC	Mon	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3120	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13D	FoC	Mon	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
3121	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13D	FoC	Mon	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
3122	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13D	FoC	Mon	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
3123	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13D	ECE	Thu	Computing Lab-10	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3124	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13D	ECE	Thu	Computing Lab-10	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3125	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13D	ECE	Thu	Computing Lab-10	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3126	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13D	FoC	Thu	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3127	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13D	FoC	Thu	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3128	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13D	FoC	Thu	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3129	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13D	FoC	Tue	Computing Lab-11	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
3130	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13D	FoC	Tue	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
3131	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13D	FoC	Tue	Computing Lab-11	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
3132	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13D	FoC	Tue	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
3133	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13D	FoC	Tue	Computing Lab-11	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	4
3134	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13D	FoC	Tue	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	4
3135	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13D	FoC	Tue	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
3136	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13D	FoC	Tue	Computing Lab-12	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
3137	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13D	FoC	Tue	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
3138	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13D	FoC	Tue	Computing Lab-12	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
3139	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13D	FoC	Tue	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
3140	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13D	FoC	Tue	Computing Lab-12	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
3141	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13D	FoC	Wed	CR-26-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3142	Dr. Hirra Anwar	Software Engineering	2K23-BSCS-13D	FoC	Wed	CR-26-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3143	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13D	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3144	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13D	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3145	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13D	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3146	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13D	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3147	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13D	FoC	Wed	CR-27-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3148	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13D	FoC	Wed	CR-27-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3149	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Fri	CR-27-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3150	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Fri	CR-27-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3151	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13E	ECE	Fri	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3152	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13E	ECE	Fri	CR-28-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3153	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13E	FoC	Fri	Computing Lab-12	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3154	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13E	FoC	Fri	Computing Lab-12	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3155	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13E	FoC	Fri	Computing Lab-12	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3156	Dr. Sarosh Tahir	Software Engineering	2K23-BSCS-13E	FoC	Mon	CR-27-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3157	Dr. Sarosh Tahir	Software Engineering	2K23-BSCS-13E	FoC	Mon	CR-27-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3158	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13E	FoC	Mon	CR-23-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3159	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13E	FoC	Mon	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3160	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13E	FoC	Mon	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3161	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13E	FoC	Mon	CR-23-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3162	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13E	FoC	Mon	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3163	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13E	FoC	Mon	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3164	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13E	FoC	Mon	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
3165	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13E	FoC	Mon	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
3166	Ms. Zahida Kausar	Big Data Analytics (Gp-03)	2K23-BSCS-13E	FoC	Mon	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
3167	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Thu	Computing Lab-11	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3168	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Thu	Computing Lab-11	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3169	Ms. Nikhar Azhar	Deep Learning	2K23-BSCS-13E	FoC	Thu	Computing Lab-11	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3170	Dr. Sarosh Tahir	Software Engineering	2K23-BSCS-13E	FoC	Tue	CR-27-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3171	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13E	FoC	Tue	Computing Lab-11	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
3172	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13E	FoC	Tue	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N	Elective		600	4
3173	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13E	FoC	Tue	Computing Lab-11	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
3174	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13E	FoC	Tue	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N	Elective		660	4
3175	Dr. Syed Imran Ali	Big Data Analytics (Gp-01)	2K23-BSCS-13E	FoC	Tue	Computing Lab-11	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	4
3176	Dr. Madiha Khalid	Cyber Security (Gp-01)	2K23-BSCS-13E	FoC	Tue	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N	Elective		720	4
3177	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13E	FoC	Tue	Computing Lab-11	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
3178	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13E	FoC	Tue	Computing Lab-12	02:00 PM	03:00 PM	Lab	\N	\N	Elective		840	4
3179	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13E	FoC	Tue	Computing Lab-11	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
3180	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13E	FoC	Tue	Computing Lab-12	03:00 PM	04:00 PM	Lab	\N	\N	Elective		900	4
3181	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13E	FoC	Tue	Computing Lab-11	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
3182	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13E	FoC	Tue	Computing Lab-12	04:00 PM	05:00 PM	Lab	\N	\N	Elective		960	4
3183	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13E	FoC	Wed	CR-27-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3184	Dr. Ayesha Maqbool	Parallel & Distributed Computing	2K23-BSCS-13E	FoC	Wed	CR-27-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3185	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13E	FoC	Wed	CR-25-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3186	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13E	FoC	Wed	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N	Elective		660	4
3187	Dr. Syed Imran Ali	Big Data Analytics (Gp-02)	2K23-BSCS-13E	FoC	Wed	CR-25-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3188	Dr. Madiha Khalid	Cyber Security (Gp-02)	2K23-BSCS-13E	FoC	Wed	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N	Elective		720	4
3189	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13E	ECE	Wed	Computing Lab-10	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3190	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13E	ECE	Wed	Computing Lab-10	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3191	Ms. Yusra Arshad	Compiler Construction	2K23-BSCS-13E	ECE	Wed	Computing Lab-10	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3192	Dr. Nazia Pervaiz	Computer Vision	2K23-BSDS-1A	FoC	Fri	CR-28-Acad Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3193	Dr. Nazia Pervaiz	Computer Vision	2K23-BSDS-1A	FoC	Fri	CR-28-Acad Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3194	Ms. Sahar Arshad	Mobile Application Development	2K23-BSDS-1A	FoC	Fri	CR-28-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3195	Ms. Sahar Arshad	Mobile Application Development	2K23-BSDS-1A	FoC	Fri	CR-28-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3196	Dr. Muhammad Moazam Fraz	Large Language Models	2K23-BSDS-1A	FoC	Fri	Computing Lab-08	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3197	Dr. Muhammad Moazam Fraz	Large Language Models	2K23-BSDS-1A	FoC	Fri	Computing Lab-08	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3198	Dr. Muhammad Moazam Fraz	Large Language Models	2K23-BSDS-1A	FoC	Fri	Computing Lab-08	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3199	Dr. Fahad Ahmed Satti	Parallel & Distributed Computing	2K23-BSDS-1A	FoC	Mon	Computing Lab-10	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3200	Dr. Fahad Ahmed Satti	Parallel & Distributed Computing	2K23-BSDS-1A	FoC	Mon	Computing Lab-10	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3201	Dr. Fahad Ahmed Satti	Parallel & Distributed Computing	2K23-BSDS-1A	FoC	Mon	Computing Lab-10	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3202	Dr. Rabia Irfan	Data Warehousing and Business Intelligence	2K23-BSDS-1A	FoC	Mon	Computing Lab-10	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3203	Dr. Rabia Irfan	Data Warehousing and Business Intelligence	2K23-BSDS-1A	FoC	Mon	Computing Lab-10	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3204	Dr. Rabia Irfan	Data Warehousing and Business Intelligence	2K23-BSDS-1A	FoC	Mon	Computing Lab-10	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3205	Dr. Nazia Pervaiz	Computer Vision	2K23-BSDS-1A	FoC	Thu	Computing Lab-12	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3206	Dr. Nazia Pervaiz	Computer Vision	2K23-BSDS-1A	FoC	Thu	Computing Lab-12	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3207	Dr. Nazia Pervaiz	Computer Vision	2K23-BSDS-1A	FoC	Thu	Computing Lab-12	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3208	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K23-BSDS-1A	H&S	Thu	CR-28-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3209	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K23-BSDS-1A	H&S	Thu	CR-28-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3210	Dr. Rabia Irfan	Data Warehousing and Business Intelligence	2K23-BSDS-1A	FoC	Tue	CR-28-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3211	Dr. Rabia Irfan	Data Warehousing and Business Intelligence	2K23-BSDS-1A	FoC	Tue	CR-28-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3212	Dr. Fahad Ahmed Satti	Parallel & Distributed Computing	2K23-BSDS-1A	FoC	Tue	CR-28-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3213	Dr. Fahad Ahmed Satti	Parallel & Distributed Computing	2K23-BSDS-1A	FoC	Tue	CR-28-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3214	Ms. Sahar Arshad	Mobile Application Development	2K23-BSDS-1A	FoC	Wed	Computing Lab-07	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3215	Ms. Sahar Arshad	Mobile Application Development	2K23-BSDS-1A	FoC	Wed	Computing Lab-07	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3216	Ms. Sahar Arshad	Mobile Application Development	2K23-BSDS-1A	FoC	Wed	Computing Lab-07	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3217	Dr. Muhammad Moazam Fraz	Large Language Models	2K23-BSDS-1A	FoC	Wed	CR-28-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3218	Dr. Muhammad Moazam Fraz	Large Language Models	2K23-BSDS-1A	FoC	Wed	CR-28-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3219	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Mon	CR-05-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3220	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16A	H&S	Mon	CR-05-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3221	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16A	H&S	Mon	CR-05-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3222	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Mon	Adv Electronics Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3223	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Mon	Adv Electronics Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3224	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Mon	Adv Electronics Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3225	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16A	ECE	Thu	Embedded Systems Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3226	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16A	ECE	Thu	Embedded Systems Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3227	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16A	ECE	Thu	Embedded Systems Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3228	Dr. Salman Abdul Ghafoor	Electromagnetic Field Theory	2K24-BEE-16A	ECE	Thu	CR-05-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3229	Dr. Salman Abdul Ghafoor	Electromagnetic Field Theory	2K24-BEE-16A	ECE	Thu	CR-05-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3230	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16A	H&S	Tue	CR-05-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3231	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Tue	CR-05-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3232	Dr. Usman Khan	Electronic Circuit Design	2K24-BEE-16A	ECE	Tue	CR-05-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3233	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16A	ECE	Tue	CR-05-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3234	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16A	H&S	Tue	CR-05-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3235	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16A	H&S	Tue	CR-05-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3236	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16A	ECE	Wed	CR-05-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3237	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16A	ECE	Wed	CR-05-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3238	Dr. Salman Abdul Ghafoor	Electromagnetic Field Theory	2K24-BEE-16A	ECE	Wed	CR-05-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3239	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16A	H&S	Wed	CR-06-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3240	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16B	ECE	Mon	Adv Electronics Lab	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3241	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16B	ECE	Mon	Adv Electronics Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3242	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16B	ECE	Mon	Adv Electronics Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3243	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16B	H&S	Mon	CR-15-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3244	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16B	H&S	Mon	CR-06-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3245	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16B	H&S	Mon	CR-06-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3246	Dr. Muhammad Mustafa Tahseen	Electromagnetic Field Theory	2K24-BEE-16B	ECE	Mon	CR-06-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3247	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Thu	CR-06-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3248	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Thu	CR-06-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3249	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Thu	Embedded Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3250	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Thu	Embedded Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3251	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Thu	Embedded Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3252	Dr. Muhammad Mustafa Tahseen	Electromagnetic Field Theory	2K24-BEE-16B	ECE	Tue	CR-06-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3253	Dr. Muhammad Mustafa Tahseen	Electromagnetic Field Theory	2K24-BEE-16B	ECE	Tue	CR-06-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3254	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16B	H&S	Tue	CR-06-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3255	Dr. Imran Shahzad	Linear Algebra	2K24-BEE-16B	H&S	Tue	CR-06-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3256	Dr. Muhammad Moazzam Ali	Microprocessor Systems	2K24-BEE-16B	ECE	Tue	CR-06-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3257	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16B	ECE	Tue	CR-06-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3258	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16B	H&S	Wed	CR-06-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3259	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16B	ECE	Wed	CR-06-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3260	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16B	ECE	Wed	CR-06-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3261	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16C	H&S	Mon	CR-07-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3262	Dr. Wasif Tanveer	Electromagnetic Field Theory	2K24-BEE-16C	ECE	Mon	CR-07-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3263	Dr. Wasif Tanveer	Electromagnetic Field Theory	2K24-BEE-16C	ECE	Mon	CR-07-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3264	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16C	H&S	Mon	CR-07-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3265	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16C	H&S	Mon	CR-07-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3266	Dr. Muhammad Saad Zia	Electronic Circuit Design	2K24-BEE-16C	ECE	Thu	CR-07-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3267	Dr. Muhammad Saad Zia	Electronic Circuit Design	2K24-BEE-16C	ECE	Thu	CR-07-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3268	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16C	ECE	Thu	CR-07-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3269	Dr. Muhammad Saad Zia	Electronic Circuit Design	2K24-BEE-16C	ECE	Thu	Adv Electronics Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3270	Dr. Muhammad Saad Zia	Electronic Circuit Design	2K24-BEE-16C	ECE	Thu	Adv Electronics Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3271	Dr. Muhammad Saad Zia	Electronic Circuit Design	2K24-BEE-16C	ECE	Thu	Adv Electronics Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3272	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16C	H&S	Tue	CR-07-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3273	Dr. Muhammad Saad Zia	Electronic Circuit Design	2K24-BEE-16C	ECE	Tue	CR-07-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3274	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16C	ECE	Tue	Embedded Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3275	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16C	ECE	Tue	Embedded Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3276	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16C	ECE	Tue	Embedded Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3277	Ms. Ayesha Habib	Expository Writing	2K24-BEE-16C	H&S	Wed	CR-07-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3278	Dr. Wasif Tanveer	Electromagnetic Field Theory	2K24-BEE-16C	ECE	Wed	CR-07-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3279	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16C	H&S	Wed	CR-07-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3280	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16C	ECE	Wed	CR-07-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3281	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16C	ECE	Wed	CR-07-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3282	Dr. Attique Dawood	Electromagnetic Field Theory	2K24-BEE-16D	ECE	Mon	CR-08-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3283	Dr. Attique Dawood	Electromagnetic Field Theory	2K24-BEE-16D	ECE	Mon	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3284	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Mon	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3285	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16D	ECE	Mon	CR-08-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3286	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16D	ECE	Mon	CR-08-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3287	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16D	H&S	Mon	CR-08-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3288	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Thu	Adv Electronics Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3289	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Thu	Adv Electronics Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3290	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Thu	Adv Electronics Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3291	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16D	ECE	Thu	CR-08-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3292	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Thu	CR-08-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3293	Dr. Neelma Riaz	Expository Writing	2K24-BEE-16D	H&S	Tue	CR-08-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3294	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16D	ECE	Tue	Embedded Systems Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3295	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16D	ECE	Tue	Embedded Systems Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3296	Dr. Muhammad Jameel Nawaz	Microprocessor Systems	2K24-BEE-16D	ECE	Tue	Embedded Systems Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3297	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Tue	CR-08-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3298	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Tue	CR-08-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3299	Dr. Attique Dawood	Electromagnetic Field Theory	2K24-BEE-16D	ECE	Wed	CR-08-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3300	Mr. Abdul Mateen	Electronic Circuit Design	2K24-BEE-16D	ECE	Wed	CR-08-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3301	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16D	H&S	Wed	CR-08-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3302	Dr. Arshad Siddiqui	Linear Algebra	2K24-BEE-16D	H&S	Wed	CR-08-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3303	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Fri	Computing Lab-04	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3304	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Fri	Computing Lab-04	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3305	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Fri	Computing Lab-04	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3306	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15A	H&S	Mon	CR-17-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3307	Ms. Ansar Shahzadi	Probability and Statistics	2K24-BESE-15A	H&S	Mon	CR-16-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3308	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Mon	Computing Lab-04	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3309	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Mon	Computing Lab-04	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3310	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Mon	Computing Lab-04	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3311	Ms. Ansar Shahzadi	Probability and Statistics	2K24-BESE-15A	H&S	Thu	CR-17-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3312	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Thu	CR-16-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3313	Dr. Zuhair Zafar	Design & Analysis of Algorithm	2K24-BESE-15A	FoC	Thu	CR-16-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3314	Ms. Ansar Shahzadi	Probability and Statistics	2K24-BESE-15A	H&S	Tue	CR-16-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3315	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15A	H&S	Tue	CR-16-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3316	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Tue	CR-16-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3317	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15A	FoC	Tue	CR-16-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3318	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Tue	CR-16-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3319	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15A	FoC	Tue	CR-16-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3320	Dr. Oumar Saleem	Islamic Studies	2K24-BESE-15A	H&S	Wed	CR-16-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3321	Dr. Oumar Saleem	Islamic Studies	2K24-BESE-15A	H&S	Wed	CR-16-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3322	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15A	H&S	Wed	CR-16-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3323	Dr. Zuhair Zafar	Design & Analysis of Algorithm	2K24-BESE-15A	FoC	Wed	CR-16-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3324	Dr. Zuhair Zafar	Design & Analysis of Algorithm	2K24-BESE-15A	FoC	Wed	CR-16-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3325	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Fri	Computing Lab-04	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3326	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Fri	Computing Lab-04	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3327	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Fri	Computing Lab-04	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3328	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15B	H&S	Mon	CR-17-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3329	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Mon	Computing Lab-04	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3330	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Mon	Computing Lab-04	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3331	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Mon	Computing Lab-04	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3332	Ms. Ansar Shahzadi	Probability and Statistics	2K24-BESE-15B	H&S	Mon	CR-15-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3333	Ms. Ansar Shahzadi	Probability and Statistics	2K24-BESE-15B	H&S	Thu	CR-17-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3334	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Thu	CR-17-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3335	Dr. Aimal Tariq Rextin	Design & Analysis of Algorithm	2K24-BESE-15B	FoC	Thu	CR-17-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3336	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15B	H&S	Tue	CR-17-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3337	Ms. Ansar Shahzadi	Probability and Statistics	2K24-BESE-15B	H&S	Tue	CR-17-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3338	Dr. Oumar Saleem	Islamic Studies	2K24-BESE-15B	H&S	Tue	CR-17-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3339	Dr. Oumar Saleem	Islamic Studies	2K24-BESE-15B	H&S	Tue	CR-17-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3340	Dr. Aimal Tariq Rextin	Design & Analysis of Algorithm	2K24-BESE-15B	FoC	Tue	CR-17-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3341	Dr. Aimal Tariq Rextin	Design & Analysis of Algorithm	2K24-BESE-15B	FoC	Tue	CR-17-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3342	Dr. Hina Munir Dutt	Complex Variables and Transforms	2K24-BESE-15B	H&S	Wed	CR-17-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3343	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Wed	CR-17-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3344	Mr. Taufiq ur Rehman	Operating Systems	2K24-BESE-15B	FoC	Wed	CR-17-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3345	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Wed	CR-17-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3346	Dr. Mehvish Rashid	Software Design and Architecture	2K24-BESE-15B	FoC	Wed	CR-17-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3347	Dr. Naima Iltaaf	Web Technologies	2K24-BSAI-1A	FoC	Fri	Computing Lab-08	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3348	Dr. Naima Iltaaf	Web Technologies	2K24-BSAI-1A	FoC	Fri	Computing Lab-08	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3349	Dr. Naima Iltaaf	Web Technologies	2K24-BSAI-1A	FoC	Fri	Computing Lab-08	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3350	Dr. Samia Tahir	Expository Writing	2K24-BSAI-1A	H&S	Mon	CR-11-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3351	Ms. Tabassam Gul	Computer Organization & Assembly Language	2K24-BSAI-1A	ECE	Mon	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3352	Ms. Tabassam Gul	Computer Organization & Assembly Language	2K24-BSAI-1A	ECE	Mon	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3353	Dr. Mehwish Fatima	Programming for AI	2K24-BSAI-1A	FoC	Mon	CR-23-Acad Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3354	Dr. Mehwish Fatima	Programming for AI	2K24-BSAI-1A	FoC	Mon	CR-23-Acad Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3355	Dr. Samia Tahir	Expository Writing	2K24-BSAI-1A	H&S	Thu	CR-11-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3356	Dr. Naima Iltaaf	Web Technologies	2K24-BSAI-1A	FoC	Thu	CR-11-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3357	Dr. Naima Iltaaf	Web Technologies	2K24-BSAI-1A	FoC	Thu	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3358	Dr. Sidra Shafiq	Applied Physics	2K24-BSAI-1A	H&S	Thu	CR-11-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3359	Dr. Seemab Latif	Machine Learning	2K24-BSAI-1A	FoC	Thu	Computing Lab-04	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3360	Dr. Seemab Latif	Machine Learning	2K24-BSAI-1A	FoC	Thu	Computing Lab-04	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3361	Dr. Seemab Latif	Machine Learning	2K24-BSAI-1A	FoC	Thu	Computing Lab-04	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3362	Dr. Samia Tahir	Expository Writing	2K24-BSAI-1A	H&S	Tue	CR-06-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3363	Dr. Mehwish Fatima	Programming for AI	2K24-BSAI-1A	FoC	Tue	Computing Lab-04	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3364	Dr. Mehwish Fatima	Programming for AI	2K24-BSAI-1A	FoC	Tue	Computing Lab-04	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3365	Dr. Mehwish Fatima	Programming for AI	2K24-BSAI-1A	FoC	Tue	Computing Lab-04	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3366	Dr. Seemab Latif	Machine Learning	2K24-BSAI-1A	FoC	Tue	CR-07-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3367	Dr. Seemab Latif	Machine Learning	2K24-BSAI-1A	FoC	Tue	CR-07-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3368	Dr. Sidra Shafiq	Applied Physics	2K24-BSAI-1A	H&S	Wed	CR-11-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3369	Ms. Tabassam Gul	Computer Organization & Assembly Language	2K24-BSAI-1A	ECE	Wed	Adv Electronics Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3370	Ms. Tabassam Gul	Computer Organization & Assembly Language	2K24-BSAI-1A	ECE	Wed	Adv Electronics Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3371	Ms. Tabassam Gul	Computer Organization & Assembly Language	2K24-BSAI-1A	ECE	Wed	Adv Electronics Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3372	Dr. Sidra Shafiq	Applied Physics	2K24-BSAI-1A	H&S	Wed	Physics Lab 01-SNS	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3373	Dr. Sidra Shafiq	Applied Physics	2K24-BSAI-1A	H&S	Wed	Physics Lab 01-SNS	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3374	Dr. Sidra Shafiq	Applied Physics	2K24-BSAI-1A	H&S	Wed	Physics Lab 01-SNS	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3375	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14A	H&S	Fri	CR-21-SMRIMMS	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3376	Dr. Muhammad Bilal Ali	Advanced Database Management Systems	2K24-BSCS-14A	FoC	Fri	Computing Lab-06	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3377	Dr. Muhammad Bilal Ali	Advanced Database Management Systems	2K24-BSCS-14A	FoC	Fri	Computing Lab-06	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3378	Dr. Muhammad Bilal Ali	Advanced Database Management Systems	2K24-BSCS-14A	FoC	Fri	Computing Lab-06	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3379	Dr. Muhammad Bilal Ali	Advanced Database Management Systems	2K24-BSCS-14A	FoC	Mon	CR-21-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3380	Dr. Muhammad Bilal Ali	Advanced Database Management Systems	2K24-BSCS-14A	FoC	Mon	CR-21-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3381	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14A	FoC	Mon	CR-21-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3382	Dr. Qaiser Riaz	Web Technologies	2K24-BSCS-14A	FoC	Mon	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3383	Dr. Qaiser Riaz	Web Technologies	2K24-BSCS-14A	FoC	Mon	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3384	Dr. Qaiser Riaz	Web Technologies	2K24-BSCS-14A	FoC	Mon	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3385	Dr. Imran Malik	Applied Physics	2K24-BSCS-14A	H&S	Thu	Physics Lab 01-SNS	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3386	Dr. Imran Malik	Applied Physics	2K24-BSCS-14A	H&S	Thu	Physics Lab 01-SNS	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3387	Dr. Imran Malik	Applied Physics	2K24-BSCS-14A	H&S	Thu	Physics Lab 01-SNS	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3388	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14A	H&S	Thu	CR-21-SMRIMMS	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3389	Dr. Imran Malik	Applied Physics	2K24-BSCS-14A	H&S	Thu	CR-21-SMRIMMS	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3390	Dr. Qaiser Riaz	Web Technologies	2K24-BSCS-14A	FoC	Tue	CR-21-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3391	Dr. Qaiser Riaz	Web Technologies	2K24-BSCS-14A	FoC	Tue	CR-21-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3392	Dr. Imran Malik	Applied Physics	2K24-BSCS-14A	H&S	Tue	CR-21-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3393	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14A	FoC	Tue	CR-21-SMRIMMS	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3394	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14A	FoC	Tue	CR-21-SMRIMMS	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3395	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14A	FoC	Wed	Control System Lab	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3396	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14A	FoC	Wed	Control System Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3397	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14A	FoC	Wed	Control System Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3398	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14A	H&S	Wed	CR-19-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3399	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14A	FoC	Wed	CR-21-SMRIMMS	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3400	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14A	FoC	Wed	CR-21-SMRIMMS	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3401	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14B	H&S	Fri	CR-21-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3402	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14B	FoC	Fri	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3403	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14B	FoC	Fri	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3404	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14B	FoC	Fri	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3405	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Mon	CR-21-SMRIMMS	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3406	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14B	FoC	Mon	Computing Lab-06	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3407	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14B	FoC	Mon	Computing Lab-06	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3408	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14B	FoC	Mon	Computing Lab-06	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3409	Dr. Imran Malik	Applied Physics	2K24-BSCS-14B	H&S	Thu	CR-21-SMRIMMS	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3410	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14B	H&S	Thu	CR-21-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3411	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14B	FoC	Thu	CR-21-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3412	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14B	FoC	Thu	CR-21-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3413	Dr. Imran Malik	Applied Physics	2K24-BSCS-14B	H&S	Thu	Physics Lab 01-SNS	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3414	Dr. Imran Malik	Applied Physics	2K24-BSCS-14B	H&S	Thu	Physics Lab 01-SNS	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3415	Dr. Imran Malik	Applied Physics	2K24-BSCS-14B	H&S	Thu	Physics Lab 01-SNS	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3416	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14B	FoC	Tue	CR-18-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3417	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14B	FoC	Tue	CR-18-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3418	Dr. Imran Malik	Applied Physics	2K24-BSCS-14B	H&S	Tue	CR-18-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3419	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14B	FoC	Tue	Lecture Hall-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3420	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14B	FoC	Tue	Lecture Hall-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3421	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14B	H&S	Wed	CR-21-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3422	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Wed	CR-21-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3423	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14B	FoC	Wed	CR-21-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3424	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14B	FoC	Wed	Control System Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3425	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14B	FoC	Wed	Control System Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3426	Mr. Omar Zeb	Computer Organization & Assembly Language	2K24-BSCS-14B	FoC	Wed	Control System Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3427	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14C	ECE	Fri	Adv Electronics Lab	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3428	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14C	ECE	Fri	Adv Electronics Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3429	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14C	ECE	Fri	Adv Electronics Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3430	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14C	H&S	Fri	CR-21-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3431	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Mon	CR-18-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3432	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Mon	CR-18-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3433	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Mon	CR-18-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3434	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14C	H&S	Thu	CR-22-SMRIMMS	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3435	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14C	ECE	Thu	CR-22-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3436	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14C	ECE	Thu	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3437	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14C	H&S	Thu	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3438	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14C	FoC	Thu	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3439	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14C	FoC	Thu	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3440	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14C	FoC	Thu	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3441	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14C	H&S	Tue	Physics Lab 01-SNS	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3442	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14C	H&S	Tue	Physics Lab 01-SNS	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3443	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14C	H&S	Tue	Physics Lab 01-SNS	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3444	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Tue	Computing Lab-06	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3445	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Tue	Computing Lab-06	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3446	Dr. Farzana Jabeen	Web Technologies	2K24-BSCS-14C	FoC	Tue	Computing Lab-06	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3447	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14C	FoC	Wed	CR-22-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3448	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14C	FoC	Wed	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3449	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14C	H&S	Wed	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3450	Ms. Hina Yousaf	Expository Writing	2K24-BSCS-14C	H&S	Wed	CR-22-SMRIMMS	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3451	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Wed	CR-22-SMRIMMS	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3452	Dr. Fatima Abdullah	Theory of Automata	2K24-BSCS-14C	FoC	Wed	CR-22-SMRIMMS	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3453	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14D	H&S	Fri	CR-22-SMRIMMS	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3454	Dr. Samia Tahir	Expository Writing	2K24-BSCS-14D	H&S	Fri	CR-22-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3455	Dr. Sohail Iqbal	Theory of Automata	2K24-BSCS-14D	FoC	Fri	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3456	Dr. Sohail Iqbal	Theory of Automata	2K24-BSCS-14D	FoC	Fri	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3457	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14D	ECE	Fri	Adv Electronics Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3458	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14D	ECE	Fri	Adv Electronics Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3459	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14D	ECE	Fri	Adv Electronics Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3460	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Mon	CR-22-SMRIMMS	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3461	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Mon	CR-22-SMRIMMS	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3462	Dr. Sohail Iqbal	Theory of Automata	2K24-BSCS-14D	FoC	Mon	CR-22-SMRIMMS	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3463	Dr. Samia Tahir	Expository Writing	2K24-BSCS-14D	H&S	Mon	CR-22-SMRIMMS	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3464	Dr. Naima Iltaaf	Web Technologies	2K24-BSCS-14D	FoC	Mon	CR-20-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3465	Dr. Naima Iltaaf	Web Technologies	2K24-BSCS-14D	FoC	Mon	CR-20-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3466	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Thu	Computing Lab-06	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3467	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Thu	Computing Lab-06	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3468	Dr. Ayesha Hakim	Advanced Database Management Systems	2K24-BSCS-14D	FoC	Thu	Computing Lab-06	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3469	Dr. Samia Tahir	Expository Writing	2K24-BSCS-14D	H&S	Thu	CR-18-IAEC	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3470	Dr. Naima Iltaaf	Web Technologies	2K24-BSCS-14D	FoC	Tue	Computing Lab-06	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3471	Dr. Naima Iltaaf	Web Technologies	2K24-BSCS-14D	FoC	Tue	Computing Lab-06	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3472	Dr. Naima Iltaaf	Web Technologies	2K24-BSCS-14D	FoC	Tue	Computing Lab-06	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3473	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14D	H&S	Tue	Physics Lab 01-SNS	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3474	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14D	H&S	Tue	Physics Lab 01-SNS	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3475	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14D	H&S	Tue	Physics Lab 01-SNS	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3476	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14D	ECE	Wed	Lecture Hall-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3477	Dr. Sara Shakil	Computer Organization & Assembly Language	2K24-BSCS-14D	ECE	Wed	Lecture Hall-IAEC	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3478	Dr. Sidra Shafiq	Applied Physics	2K24-BSCS-14D	H&S	Wed	Lecture Hall-IAEC	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3479	Dr. Samia Tahir	Expository Writing	2K24-BSDS-2A	H&S	Fri	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3480	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Fri	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3481	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Fri	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3482	Dr. Samia Tahir	Expository Writing	2K24-BSDS-2A	H&S	Mon	CR-11-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3483	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Mon	Control System Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3484	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Mon	Control System Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3485	Ms. Naema Asif	Computer Organization & Assembly Language	2K24-BSDS-2A	FoC	Mon	Control System Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3486	Ms. Ansar Shahzadi	Advanced Statistics	2K24-BSDS-2A	H&S	Mon	CR-12-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3487	Dr. Rabia Irfan	Introduction to Data Science	2K24-BSDS-2A	FoC	Mon	CR-12-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3488	Dr. Rabia Irfan	Introduction to Data Science	2K24-BSDS-2A	FoC	Mon	CR-12-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3489	Dr. Nazia Pervaiz	Machine Learning	2K24-BSDS-2A	FoC	Thu	CR-12-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3490	Dr. Nazia Pervaiz	Machine Learning	2K24-BSDS-2A	FoC	Thu	CR-12-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3491	Dr. Samia Tahir	Expository Writing	2K24-BSDS-2A	H&S	Thu	CR-12-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3492	Ms. Ansar Shahzadi	Advanced Statistics	2K24-BSDS-2A	H&S	Thu	CR-12-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3493	Dr. Imran Malik	Applied Physics	2K24-BSDS-2A	H&S	Thu	CR-14-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3494	Dr. Imran Malik	Applied Physics	2K24-BSDS-2A	H&S	Tue	CR-10-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3495	Dr. Rabia Irfan	Introduction to Data Science	2K24-BSDS-2A	FoC	Tue	Computing Lab-03	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3496	Dr. Rabia Irfan	Introduction to Data Science	2K24-BSDS-2A	FoC	Tue	Computing Lab-03	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3497	Dr. Rabia Irfan	Introduction to Data Science	2K24-BSDS-2A	FoC	Tue	Computing Lab-03	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3498	Ms. Ansar Shahzadi	Advanced Statistics	2K24-BSDS-2A	H&S	Tue	Computing Lab-08	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3499	Ms. Ansar Shahzadi	Advanced Statistics	2K24-BSDS-2A	H&S	Tue	Computing Lab-08	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3500	Ms. Ansar Shahzadi	Advanced Statistics	2K24-BSDS-2A	H&S	Tue	Computing Lab-08	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3501	Dr. Imran Malik	Applied Physics	2K24-BSDS-2A	H&S	Wed	Physics Lab 01-SNS	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3502	Dr. Imran Malik	Applied Physics	2K24-BSDS-2A	H&S	Wed	Physics Lab 01-SNS	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3503	Dr. Imran Malik	Applied Physics	2K24-BSDS-2A	H&S	Wed	Physics Lab 01-SNS	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3504	Dr. Nazia Pervaiz	Machine Learning	2K24-BSDS-2A	FoC	Wed	Computing Lab-08	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3505	Dr. Nazia Pervaiz	Machine Learning	2K24-BSDS-2A	FoC	Wed	Computing Lab-08	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3506	Dr. Nazia Pervaiz	Machine Learning	2K24-BSDS-2A	FoC	Wed	Computing Lab-08	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3507	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K25-BCE-1A	H&S	Fri	CR-13-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3508	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K25-BCE-1A	H&S	Fri	CR-13-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3509	Dr. Sadiq Amin	Fundamentals of Programming	2K25-BCE-1A	ECE	Mon	Computing Lab-01	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3510	Dr. Sadiq Amin	Fundamentals of Programming	2K25-BCE-1A	ECE	Mon	Computing Lab-01	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3511	Dr. Sadiq Amin	Fundamentals of Programming	2K25-BCE-1A	ECE	Mon	Computing Lab-01	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3512	Dr. Sadiq Amin	Fundamentals of Programming	2K25-BCE-1A	ECE	Mon	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3513	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BCE-1A	H&S	Mon	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3514	Dr. Ahmed Naeem	Logic and Sequential Circuit Design	2K25-BCE-1A	ECE	Mon	CR-13-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3515	Dr. Ahmed Naeem	Logic and Sequential Circuit Design	2K25-BCE-1A	ECE	Mon	CR-13-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3516	Dr. Fahd Sikandar Khan	Electrical Network Analysis	2K25-BCE-1A	FoC	Thu	Basic Electronics Lab	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3517	Dr. Fahd Sikandar Khan	Electrical Network Analysis	2K25-BCE-1A	FoC	Thu	Basic Electronics Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3518	Dr. Fahd Sikandar Khan	Electrical Network Analysis	2K25-BCE-1A	FoC	Thu	Basic Electronics Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3519	Dr. Fahd Sikandar Khan	Electrical Network Analysis	2K25-BCE-1A	FoC	Thu	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3520	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3521	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3522	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3523	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3524	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3525	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BCE-1A	H&S	Thu	CR-13-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3526	Dr. Ahmed Naeem	Logic and Sequential Circuit Design	2K25-BCE-1A	ECE	Tue	CR-13-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3527	Dr. Fahd Sikandar Khan	Electrical Network Analysis	2K25-BCE-1A	FoC	Tue	CR-13-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3528	Dr. Fahd Sikandar Khan	Electrical Network Analysis	2K25-BCE-1A	FoC	Tue	CR-13-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3529	Dr. Sadiq Amin	Fundamentals of Programming	2K25-BCE-1A	ECE	Tue	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3530	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BCE-1A	H&S	Tue	CR-13-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3531	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BCE-1A	H&S	Wed	CR-13-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3532	Dr. Ahmed Naeem	Logic and Sequential Circuit Design	2K25-BCE-1A	ECE	Wed	Digital Systems Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3533	Dr. Ahmed Naeem	Logic and Sequential Circuit Design	2K25-BCE-1A	ECE	Wed	Digital Systems Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3534	Dr. Ahmed Naeem	Logic and Sequential Circuit Design	2K25-BCE-1A	ECE	Wed	Digital Systems Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3535	Mr. Jamil Ahmad	Workshop Practice	2K25-BCE-1A	ECE	Wed	MRC Lab 01- SMME	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3536	Mr. Jamil Ahmad	Workshop Practice	2K25-BCE-1A	ECE	Wed	MRC Lab 01- SMME	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3537	Mr. Jamil Ahmad	Workshop Practice	2K25-BCE-1A	ECE	Wed	MRC Lab 01- SMME	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3538	Dr. Sadiq Amin	Computer Programming	2K25-BEE-17A	ECE	Fri	CR-05-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3539	Dr. Azad Akhtar Siddiqui	Differential Equations	2K25-BEE-17A	H&S	Fri	CR-05-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3540	Mr. Saif Ullah	Understanding of Quran II	2K25-BEE-17A	H&S	Fri	CR-14-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3541	Mr. Saif Ullah	Understanding of Quran II	2K25-BEE-17A	H&S	Fri	CR-14-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3542	Mr. Saif Ullah	Understanding of Quran II	2K25-BEE-17A	H&S	Fri	CR-14-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3543	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Mon	CR-14-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3544	Dr. Sadiq Amin	Computer Programming	2K25-BEE-17A	ECE	Mon	Computing Lab-08	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3545	Dr. Sadiq Amin	Computer Programming	2K25-BEE-17A	ECE	Mon	Computing Lab-08	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3546	Dr. Sadiq Amin	Computer Programming	2K25-BEE-17A	ECE	Mon	Computing Lab-08	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3547	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17A	ECE	Thu	MRC Lab 01- SMME	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3548	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17A	ECE	Thu	MRC Lab 01- SMME	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3549	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17A	ECE	Thu	MRC Lab 01- SMME	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3550	Dr. Azad Akhtar Siddiqui	Differential Equations	2K25-BEE-17A	H&S	Thu	CR-14-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3551	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17A	H&S	Tue	CR-14-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3552	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Tue	Basic Electronics Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3553	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Tue	Basic Electronics Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3554	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Tue	Basic Electronics Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3555	Dr. Sadiq Amin	Computer Programming	2K25-BEE-17A	ECE	Tue	CR-14-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3556	Dr. Sadiq Amin	Computer Programming	2K25-BEE-17A	ECE	Tue	CR-14-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3557	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17A	H&S	Wed	CR-14-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3558	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17A	H&S	Wed	CR-14-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3559	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17A	H&S	Wed	CR-14-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3560	Dr. Azad Akhtar Siddiqui	Differential Equations	2K25-BEE-17A	H&S	Wed	CR-14-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3561	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Wed	CR-14-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3562	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17A	ECE	Wed	CR-14-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3563	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BEE-17B	H&S	Fri	CR-14-UG Block	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3564	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BEE-17B	H&S	Fri	CR-14-UG Block	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3565	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BEE-17B	H&S	Fri	CR-14-UG Block	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3566	Dr. Azad Akhtar Siddiqui	Differential Equations	2K25-BEE-17B	H&S	Fri	CR-14-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3567	Mr. Hassan Jamil	Computer Programming	2K25-BEE-17B	FoC	Mon	Computing Lab-08	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3568	Mr. Hassan Jamil	Computer Programming	2K25-BEE-17B	FoC	Mon	Computing Lab-08	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3569	Mr. Hassan Jamil	Computer Programming	2K25-BEE-17B	FoC	Mon	Computing Lab-08	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3570	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Mon	CR-14-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3571	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Mon	CR-14-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3572	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17B	H&S	Thu	CR-14-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3573	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17B	H&S	Thu	CR-14-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3574	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2K25-BEE-17B	H&S	Thu	CR-14-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3575	Dr. Azad Akhtar Siddiqui	Differential Equations	2K25-BEE-17B	H&S	Thu	CR-14-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3576	Mr. Hassan Jamil	Computer Programming	2K25-BEE-17B	FoC	Thu	CR-10-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3577	Mr. Hassan Jamil	Computer Programming	2K25-BEE-17B	FoC	Thu	CR-10-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3578	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17B	H&S	Tue	CR-08-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3579	Mr. Hassan Jamil	Computer Programming	2K25-BEE-17B	FoC	Tue	CR-14-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3580	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Tue	Basic Electronics Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3581	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Tue	Basic Electronics Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3582	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Tue	Basic Electronics Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3583	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17B	ECE	Wed	MRC Lab 01- SMME	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3584	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17B	ECE	Wed	MRC Lab 01- SMME	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3585	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17B	ECE	Wed	MRC Lab 01- SMME	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3586	Mr. Ahsan Azhar	Electrical Network Analysis	2K25-BEE-17B	ECE	Wed	CR-13-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3587	Dr. Azad Akhtar Siddiqui	Differential Equations	2K25-BEE-17B	H&S	Wed	CR-13-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3588	Dr. Ibrar Hussain	Differential Equations	2k25-BEE-17C	H&S	Fri	CR-15-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3589	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	FoC	Fri	CR-15-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3590	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	CR-28-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3591	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	CR-28-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3592	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	Basic Electronics Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3593	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	Basic Electronics Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3594	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Mon	Basic Electronics Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3595	Mr. Salman Mushtaq	Understanding of Quran II	2k25-BEE-17C	H&S	Thu	CR-15-UG Block	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3596	Mr. Salman Mushtaq	Understanding of Quran II	2k25-BEE-17C	H&S	Thu	CR-15-UG Block	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3597	Mr. Salman Mushtaq	Understanding of Quran II	2k25-BEE-17C	H&S	Thu	CR-15-UG Block	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3598	Mr. Ammar Ahmed	Islamic Studies	2k25-BEE-17C	H&S	Thu	CR-15-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3599	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2k25-BEE-17C	H&S	Thu	CR-15-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3600	Dr. Sobia Jamil	Ideology and Constitution of Pakistan	2k25-BEE-17C	H&S	Thu	CR-15-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3601	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	FoC	Tue	CR-15-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3602	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	FoC	Tue	CR-15-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3603	Mr. Ammar Ahmed	Islamic Studies	2k25-BEE-17C	H&S	Tue	CR-15-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3604	Dr. Nosherwan Shoaib	Electrical Network Analysis	2k25-BEE-17C	ECE	Tue	CR-15-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3605	Dr. Ibrar Hussain	Differential Equations	2k25-BEE-17C	H&S	Tue	CR-15-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3606	Dr. Ibrar Hussain	Differential Equations	2k25-BEE-17C	H&S	Tue	CR-15-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3607	Mr. Jamil Ahmad	Workshop Practice	2k25-BEE-17C	ECE	Wed	MRC Lab 01- SMME	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3608	Mr. Jamil Ahmad	Workshop Practice	2k25-BEE-17C	ECE	Wed	MRC Lab 01- SMME	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3609	Mr. Jamil Ahmad	Workshop Practice	2k25-BEE-17C	ECE	Wed	MRC Lab 01- SMME	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3610	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	FoC	Wed	Computing Lab-07	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3611	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	FoC	Wed	Computing Lab-07	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3612	Mr. Huzaifa Abbas	Computer Programming	2k25-BEE-17C	FoC	Wed	Computing Lab-07	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3613	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Fri	CR-15-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3614	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Fri	Computing Lab-07	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3615	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Fri	Computing Lab-07	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3616	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Fri	Computing Lab-07	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3617	Mr. Habeel Ahmed	Electrical Network Analysis	2K25-BEE-17D	ECE	Mon	Basic Electronics Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3618	Mr. Habeel Ahmad	Electrical Network Analysis	2K25-BEE-17D	ECE	Mon	Basic Electronics Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3619	Mr. Habeel Ahmad	Electrical Network Analysis	2K25-BEE-17D	ECE	Mon	Basic Electronics Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3620	Dr. Hina Munir Dutt	Differential Equations	2K25-BEE-17D	H&S	Mon	CR-15-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3621	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17D	ECE	Thu	MRC Lab 01- SMME	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3622	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17D	ECE	Thu	MRC Lab 01- SMME	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3623	Mr. Jamil Ahmad	Workshop Practice	2K25-BEE-17D	ECE	Thu	MRC Lab 01- SMME	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3624	Mr. Saif Ullah	Understanding of Quran II	2K25-BEE-17D	H&S	Thu	CR-11-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3625	Mr. Saif Ullah	Understanding of Quran II	2K25-BEE-17D	H&S	Thu	CR-11-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3626	Mr. Saif Ullah	Understanding of Quran II	2K25-BEE-17D	H&S	Thu	CR-11-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3627	Mr. Habeel Ahmad	Electrical Network Analysis	2K25-BEE-17D	ECE	Tue	CR-07-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3628	Mr. Habeel Ahmad	Electrical Network Analysis	2K25-BEE-17D	ECE	Tue	CR-07-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3629	Dr. Hina Munir Dutt	Differential Equations	2K25-BEE-17D	H&S	Tue	CR-09-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3630	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Tue	CR-19-IAEC	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3631	Dr. Fahd Sikandar Khan	Computer Programming	2K25-BEE-17D	FoC	Tue	CR-19-IAEC	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3632	Mr. Habeel Ahmad	Electrical Network Analysis	2K25-BEE-17D	ECE	Wed	CR-15-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3633	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17D	H&S	Wed	CR-15-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3634	Mr. Ammar Ahmed	Islamic Studies	2K25-BEE-17D	H&S	Wed	CR-15-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3635	Dr. Hina Munir Dutt	Differential Equations	2K25-BEE-17D	H&S	Wed	CR-15-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3636	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K25-BEE-17D	H&S	Wed	CR-15-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3637	Ms. Maria Jamshaid	Ideology and Constitution of Pakistan	2K25-BEE-17D	H&S	Wed	CR-15-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3638	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16A	H&S	Fri	CR-04-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3639	Dr. Aimal Tariq Rextin	Object Oriented Programming	2K25-BESE-16A	FoC	Fri	CR-09-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3640	Dr. Aimal Tariq Rextin	Object Oriented Programming	2K25-BESE-16A	FoC	Fri	CR-09-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3641	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BESE-16A	H&S	Mon	CR-09-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3642	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2K25-BESE-16A	FoC	Mon	CR-09-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3643	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2K25-BESE-16A	FoC	Mon	CR-09-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3644	Dr. Aimal Tariq Rextin	Object Oriented Programming	2K25-BESE-16A	FoC	Mon	Computing Lab-03	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3645	Dr. Aimal Tariq Rextin	Object Oriented Programming	2K25-BESE-16A	FoC	Mon	Computing Lab-03	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3646	Dr. Aimal Tariq Rextin	Object Oriented Programming	2K25-BESE-16A	FoC	Mon	Computing Lab-03	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3647	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2K25-BESE-16A	FoC	Thu	CR-09-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3648	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2K25-BESE-16A	FoC	Thu	Digital Systems Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3649	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2K25-BESE-16A	FoC	Thu	Digital Systems Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3650	Dr. Muhammad Ashraf	Computer Architecture & Logic Design	2K25-BESE-16A	FoC	Thu	Digital Systems Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3651	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Thu	CR-09-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3652	Dr. Aimal Tariq Rextin	Object Oriented Programming	2K25-BESE-16A	FoC	Thu	CR-09-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3653	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BESE-16A	H&S	Tue	CR-09-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3654	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Tue	CR-09-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3655	Dr. Neelma Riaz	Functional English	2K25-BESE-16A	H&S	Tue	CR-09-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3656	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16A	H&S	Wed	CR-01-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3657	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16A	H&S	Wed	CR-01-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3658	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BESE-16A	H&S	Wed	CR-09-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3659	Mr. Saif Ullah	Understanding of Quran II	2K25-BESE-16A	H&S	Wed	CR-09-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3660	Mr. Saif Ullah	Understanding of Quran II	2K25-BESE-16A	H&S	Wed	CR-09-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3661	Mr. Saif Ullah	Understanding of Quran II	2K25-BESE-16A	H&S	Wed	CR-09-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3662	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16B	H&S	Fri	CR-04-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3663	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Fri	CR-10-UG Block	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3664	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Fri	CR-10-UG Block	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3665	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Fri	CR-10-UG Block	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3666	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Fri	CR-10-UG Block	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3667	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Fri	CR-10-UG Block	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3668	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BESE-16B	H&S	Fri	CR-10-UG Block	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3669	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BESE-16B	H&S	Mon	CR-10-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3670	Dr. Muhammad Daud Abdullah Asif	Object Oriented Programming	2K25-BESE-16B	FoC	Mon	Computing Lab-03	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3671	Dr. Muhammad Daud Abdullah Asif	Object Oriented Programming	2K25-BESE-16B	FoC	Mon	Computing Lab-03	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3672	Dr. Muhammad Daud Abdullah Asif	Object Oriented Programming	2K25-BESE-16B	FoC	Mon	Computing Lab-03	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3673	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	FoC	Mon	CR-10-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3674	Dr. Muhammad Daud Abdullah Asif	Object Oriented Programming	2K25-BESE-16B	FoC	Mon	CR-10-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3675	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16B	H&S	Thu	Lecture Hall-PG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3676	Dr. Quanita Kiran	Discrete Mathematics	2K25-BESE-16B	H&S	Thu	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3677	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	FoC	Thu	Digital Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3678	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	FoC	Thu	Digital Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3679	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	FoC	Thu	Digital Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3680	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BESE-16B	H&S	Tue	CR-10-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3681	Ms. Sadia Arshad	Functional English	2K25-BESE-16B	H&S	Tue	CR-10-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3682	Ms. Sadia Arshad	Functional English	2K25-BESE-16B	H&S	Tue	CR-10-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3683	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	FoC	Tue	CR-10-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3684	Mr. Muhammad Nashit Shah	Computer Architecture & Logic Design	2K25-BESE-16B	FoC	Tue	CR-10-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3685	Ms. Sadia Arshad	Functional English	2K25-BESE-16B	H&S	Wed	CR-10-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3686	Dr. Saira Zainab	Linear Algebra & ODEs	2K25-BESE-16B	H&S	Wed	CR-10-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3687	Dr. Muhammad Daud Abdullah Asif	Object Oriented Programming	2K25-BESE-16B	FoC	Wed	CR-10-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3688	Dr. Muhammad Daud Abdullah Asif	Object Oriented Programming	2K25-BESE-16B	FoC	Wed	CR-10-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3689	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAI-2A	FoC	Fri	CR-01-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3690	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSAI-2A	ECE	Fri	Digital Systems Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3691	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSAI-2A	ECE	Fri	Digital Systems Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3692	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSAI-2A	ECE	Fri	Digital Systems Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3693	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSAI-2A	H&S	Fri	CR-05-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3694	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSAI-2A	H&S	Fri	CR-05-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3695	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSAI-2A	H&S	Fri	CR-05-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3696	Dr. Atifa Kanwal	Multivariable Calculus	2K25-BSAI-2A	H&S	Mon	CR-01-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3697	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAI-2A	FoC	Mon	CR-01-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3698	Mr. Saeed Afzal	Linear Algebra	2K25-BSAI-2A	H&S	Mon	CR-01-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3699	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSAI-2A	ECE	Mon	CR-01-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3700	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSAI-2A	ECE	Mon	CR-01-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3701	Mr. Saeed Afzal	Linear Algebra	2K25-BSAI-2A	H&S	Thu	CR-16-IAEC	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3702	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAI-2A	FoC	Thu	Computing Lab-01	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3703	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAI-2A	FoC	Thu	Computing Lab-01	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3704	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAI-2A	FoC	Thu	Computing Lab-01	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3705	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAI-2A	FoC	Tue	CR-01-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3706	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAI-2A	FoC	Tue	CR-01-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3707	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSAI-2A	FoC	Tue	CR-01-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3708	Mr. Saeed Afzal	Linear Algebra	2K25-BSAI-2A	H&S	Wed	Lecture Hall-PG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3709	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAI-2A	FoC	Wed	Lecture Hall-PG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3710	Dr. Atifa Kanwal	Multivariable Calculus	2K25-BSAI-2A	H&S	Wed	Lecture Hall-PG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3711	Dr. Atifa Kanwal	Multivariable Calculus	2K25-BSAI-2A	H&S	Wed	Lecture Hall-PG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3712	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAI-2A	FoC	Wed	Computing Lab-01	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3713	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAI-2A	FoC	Wed	Computing Lab-01	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3714	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSAI-2A	FoC	Wed	Computing Lab-01	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3715	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Fri	CR-02-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3716	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15A	ECE	Fri	CR-02-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3717	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Fri	Computing Lab-05	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3718	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Fri	Computing Lab-05	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3719	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Fri	Computing Lab-05	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3720	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15A	H&S	Mon	CR-02-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3721	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Mon	CR-02-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3722	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Mon	CR-02-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3723	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15A	ECE	Mon	Digital Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3724	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15A	ECE	Mon	Digital Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3725	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15A	ECE	Mon	Digital Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3726	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Thu	CR-03-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3727	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Thu	CR-03-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3728	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15A	H&S	Thu	CR-03-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3729	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15A	H&S	Thu	CR-03-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3730	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15A	ECE	Thu	CR-05-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3731	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15A	H&S	Tue	CR-03-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3732	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Tue	Computing Lab-05	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3733	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Tue	Computing Lab-05	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3734	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15A	FoC	Tue	Computing Lab-05	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3735	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3736	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3737	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15A	FoC	Wed	CR-02-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3738	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3739	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3740	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15A	H&S	Wed	CR-02-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3741	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Fri	Computing Lab-05	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3742	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Fri	Computing Lab-05	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3743	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Fri	Computing Lab-05	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3744	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15B	H&S	Fri	CR-05-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3745	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15B	FoC	Fri	CR-02-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3746	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15B	FoC	Fri	CR-02-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3747	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Mon	CR-01-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3748	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Mon	Digital Systems Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3749	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Mon	Digital Systems Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3750	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Mon	Digital Systems Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3751	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15B	H&S	Mon	CR-02-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3752	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Thu	CR-02-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3753	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15B	FoC	Thu	CR-02-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3754	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15B	H&S	Thu	CR-02-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3755	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15B	H&S	Thu	CR-02-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3756	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Tue	CR-02-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3757	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15B	FoC	Tue	CR-02-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3758	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15B	ECE	Tue	CR-02-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3759	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15B	H&S	Tue	CR-02-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3760	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15B	FoC	Tue	Computing Lab-05	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3761	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15B	FoC	Tue	Computing Lab-05	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3762	Ms. Maryam Sajjad	Database Systems	2K25-BSCS-15B	FoC	Tue	Computing Lab-05	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3763	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15B	H&S	Wed	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3764	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Wed	CR-04-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3765	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Wed	CR-11-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3766	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Wed	CR-04-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3767	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Wed	CR-11-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3768	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Wed	CR-04-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3769	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15B	H&S	Wed	CR-11-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3770	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Fri	CR-03-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3771	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Fri	CR-03-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3772	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Fri	CR-03-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3773	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15C	H&S	Fri	CR-03-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3774	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15C	H&S	Fri	CR-03-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3775	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15C	H&S	Mon	CR-04-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3776	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15C	H&S	Mon	CR-03-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3777	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15C	H&S	Mon	CR-03-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3778	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15C	H&S	Mon	CR-03-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3779	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Thu	Computing Lab-05	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3780	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Thu	Computing Lab-05	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3781	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Thu	Computing Lab-05	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3782	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Thu	CR-02-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3783	Dr. Zafar Ali	Linear Algebra	2K25-BSCS-15C	H&S	Thu	CR-03-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3784	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15C	H&S	Tue	CR-03-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3785	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Tue	CR-03-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3786	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Tue	CR-03-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3787	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Tue	Digital Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3788	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Tue	Digital Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3789	Mr. Arshad Nazir	Digital Logic Design	2K25-BSCS-15C	ECE	Tue	Digital Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3790	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Wed	CR-03-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3791	Mr. Jaudat Mamoon	Object Oriented Programming	2K25-BSCS-15C	FoC	Wed	CR-03-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3792	Dr. Khursheed Muhammad	Multivariable Calculus	2K25-BSCS-15C	H&S	Wed	CR-08-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3793	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Wed	Computing Lab-05	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3794	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Wed	Computing Lab-05	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3795	Dr. Muhammad Bilal Ali	Database Systems	2K25-BSCS-15C	FoC	Wed	Computing Lab-05	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3796	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15D	ECE	Fri	CR-06-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3797	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15D	ECE	Fri	CR-06-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3798	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15D	H&S	Fri	CR-06-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3799	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15D	H&S	Fri	CR-06-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3800	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15D	H&S	Mon	CR-03-UG Block	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3801	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15D	H&S	Mon	CR-03-UG Block	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3802	Mr. Salman Mushtaq	Understanding of Quran II	2K25-BSCS-15D	H&S	Mon	CR-03-UG Block	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3803	Ms. Ayesha Kanwal	Object Oriented Programming	2K25-BSCS-15D	FoC	Mon	CR-03-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3804	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Mon	Computing Lab-05	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3805	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Mon	Computing Lab-05	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3806	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Mon	Computing Lab-05	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3807	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15D	H&S	Thu	CR-02-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3808	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15D	H&S	Thu	CR-02-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3809	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Thu	CR-10-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3810	Ms. Ayesha Kanwal	Object Oriented Programming	2K25-BSCS-15D	FoC	Thu	Computing Lab-05	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3811	Ms. Ayesha Kanwal	Object Oriented Programming	2K25-BSCS-15D	FoC	Thu	Computing Lab-05	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3812	Ms. Ayesha Kanwal	Object Oriented Programming	2K25-BSCS-15D	FoC	Thu	Computing Lab-05	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3813	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15D	ECE	Tue	Digital Systems Lab	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3814	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15D	ECE	Tue	Digital Systems Lab	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3815	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15D	ECE	Tue	Digital Systems Lab	12:00 PM	01:00 PM	Lab	\N	\N			720	4
3816	Ms. Ayesha Kanwal	Object Oriented Programming	2K25-BSCS-15D	FoC	Tue	CR-03-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3817	Ms. Ayesha Kanwal	Object Oriented Programming	2K25-BSCS-15D	FoC	Tue	CR-03-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3818	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15D	H&S	Wed	CR-03-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3819	Dr. Abdul Haleem Hamid	Linear Algebra	2K25-BSCS-15D	H&S	Wed	CR-03-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3820	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Wed	CR-03-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3821	Ms. Sara Tariq Sheikh	Database Systems	2K25-BSCS-15D	FoC	Wed	CR-03-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3822	Dr. Atifa Kanwal	Calculus & Analytical Geometry	2K25-BSCS-15E	H&S	Fri	CR-11-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3823	Dr. Atifa Kanwal	Calculus & Analytical Geometry	2K25-BSCS-15E	H&S	Fri	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3824	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Fri	CR-04-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3825	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Fri	CR-04-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3826	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Fri	CR-04-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3827	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Fri	CR-04-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3828	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Fri	CR-04-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3829	Mr. Muhammad Usman Ghani	Understanding of Quran II	2K25-BSCS-15E	H&S	Fri	CR-04-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3830	Dr. Hirra Anwar	Database Systems	2K25-BSCS-15E	FoC	Mon	Computing Lab-05	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3831	Dr. Hirra Anwar	Database Systems	2K25-BSCS-15E	FoC	Mon	Computing Lab-05	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3832	Dr. Hirra Anwar	Database Systems	2K25-BSCS-15E	FoC	Mon	Computing Lab-05	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3833	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSCS-15E	H&S	Mon	CR-02-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3834	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15E	H&S	Mon	CR-04-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3835	Dr. Sarosh Tahir	Object Oriented Programming	2K25-BSCS-15E	FoC	Mon	CR-04-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3836	Dr. Rai Sajjad Saif	Linear Algebra	2K25-BSCS-15E	H&S	Mon	CR-04-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3837	Dr. Rai Sajjad Saif	Linear Algebra	2K25-BSCS-15E	H&S	Mon	CR-04-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3838	Dr. Atifa Kanwal	Calculus & Analytical Geometry	2K25-BSCS-15E	H&S	Thu	CR-06-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3839	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15E	H&S	Thu	CR-04-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3840	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSCS-15E	H&S	Thu	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3841	Dr. Farkhanda Afzal	Multivariable Calculus	2K25-BSCS-15E	H&S	Thu	CR-04-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3842	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSCS-15E	H&S	Thu	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3843	Dr. Hirra Anwar	Database Systems	2K25-BSCS-15E	FoC	Thu	CR-04-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3844	Dr. Hirra Anwar	Database Systems	2K25-BSCS-15E	FoC	Thu	CR-04-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3845	Dr. Rai Sajjad Saif	Linear Algebra	2K25-BSCS-15E	H&S	Thu	CR-04-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3846	Dr. Sarosh Tahir	Object Oriented Programming	2K25-BSCS-15E	FoC	Tue	CR-04-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3847	Dr. Sarosh Tahir	Object Oriented Programming	2K25-BSCS-15E	FoC	Tue	CR-04-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3848	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15E	ECE	Tue	CR-04-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3849	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15E	ECE	Tue	CR-04-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3850	Dr. Sarosh Tahir	Object Oriented Programming	2K25-BSCS-15E	FoC	Wed	Computing Lab-05	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3851	Dr. Sarosh Tahir	Object Oriented Programming	2K25-BSCS-15E	FoC	Wed	Computing Lab-05	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3852	Dr. Sarosh Tahir	Object Oriented Programming	2K25-BSCS-15E	FoC	Wed	Computing Lab-05	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3853	Dr. Hirra Anwar	Database Systems	2K25-BSCS-15E	FoC	Wed	CR-09-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3854	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15E	ECE	Wed	Digital Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3855	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15E	ECE	Wed	Digital Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3856	Mr. Habeel Ahmad	Digital Logic Design	2K25-BSCS-15E	ECE	Wed	Digital Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3857	Dr. Atifa Kanwal	Calculus & Analytical Geometry	2K25-BSDS-3A	H&S	Fri	CR-11-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3858	Dr. Bilal Ahmed	Linear Algebra	2K25-BSDS-3A	H&S	Fri	CR-04-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3859	Dr. Atifa Kanwal	Calculus & Analytical Geometry	2K25-BSDS-3A	H&S	Fri	CR-11-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3860	Dr. Bilal Ahmed	Linear Algebra	2K25-BSDS-3A	H&S	Fri	CR-04-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3861	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSDS-3A	ECE	Fri	Digital Systems Lab	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3862	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSDS-3A	ECE	Fri	Digital Systems Lab	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3863	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSDS-3A	ECE	Fri	Digital Systems Lab	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3864	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSDS-3A	FoC	Mon	Computing Lab-02	09:00 AM	10:00 AM	Lab	\N	\N			540	4
3865	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSDS-3A	FoC	Mon	Computing Lab-02	10:00 AM	11:00 AM	Lab	\N	\N			600	4
3866	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSDS-3A	FoC	Mon	Computing Lab-02	11:00 AM	12:00 PM	Lab	\N	\N			660	4
3867	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSDS-3A	H&S	Mon	CR-02-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3868	Dr. Atifa Kanwal	Multivariable Calculus	2K25-BSDS-3A	H&S	Mon	CR-14-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3869	Dr. Fahad Ahmed Satti	Database Systems	2K25-BSDS-3A	FoC	Mon	Computing Lab-02	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3870	Dr. Fahad Ahmed Satti	Database Systems	2K25-BSDS-3A	FoC	Mon	Computing Lab-02	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3871	Dr. Fahad Ahmed Satti	Database Systems	2K25-BSDS-3A	FoC	Mon	Computing Lab-02	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3872	Dr. Atifa Kanwal	Calculus & Analytical Geometry	2K25-BSDS-3A	H&S	Thu	CR-06-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3873	Dr. Atifa Kanwal	Multivariable Calculus	2K25-BSDS-3A	H&S	Thu	CR-01-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3874	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSDS-3A	H&S	Thu	CR-27-Acad Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3875	Dr. Adnan Aslam	Discrete Mathematics	2K25-BSDS-3A	H&S	Thu	CR-27-Acad Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3876	Dr. Atifa Kanwal	Multivariable Calculus	2K25-BSDS-3A	H&S	Thu	CR-01-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3877	Dr. Fahad Ahmed Satti	Database Systems	2K25-BSDS-3A	FoC	Thu	CR-01-UG Block	02:00 PM	03:00 PM	Lec	\N	\N			840	4
3878	Dr. Fahad Ahmed Satti	Database Systems	2K25-BSDS-3A	FoC	Thu	CR-01-UG Block	03:00 PM	04:00 PM	Lec	\N	\N			900	4
3879	Dr. Bilal Ahmed	Linear Algebra	2K25-BSDS-3A	H&S	Thu	CR-01-UG Block	04:00 PM	05:00 PM	Lec	\N	\N			960	4
3880	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSDS-3A	FoC	Tue	CR-14-UG Block	10:00 AM	11:00 AM	Lec	\N	\N			600	4
3881	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSDS-3A	FoC	Tue	CR-14-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3882	Dr. Fahad Ahmed Satti	Database Systems	2K25-BSDS-3A	FoC	Tue	CR-01-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3883	Ms. Sahar Arshad	Object Oriented Programming	2K25-BSDS-3A	FoC	Wed	CR-14-UG Block	09:00 AM	10:00 AM	Lec	\N	\N			540	4
3884	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSDS-3A	ECE	Wed	CR-01-UG Block	11:00 AM	12:00 PM	Lec	\N	\N			660	4
3885	Mr. Muhammad Abdullah	Digital Logic Design	2K25-BSDS-3A	ECE	Wed	CR-01-UG Block	12:00 PM	01:00 PM	Lec	\N	\N			720	4
3886	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSDS-3A	H&S	Wed	CR-01-UG Block	02:00 PM	03:00 PM	Lab	\N	\N			840	4
3887	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSDS-3A	H&S	Wed	CR-01-UG Block	03:00 PM	04:00 PM	Lab	\N	\N			900	4
3888	Hafiz Muhammad Siddique	Understanding of Quran II	2K25-BSDS-3A	H&S	Wed	CR-01-UG Block	04:00 PM	05:00 PM	Lab	\N	\N			960	4
3889	Dr. Aimal Tariq Rextin	Design & Analysis of Algorithm	2K24-BESE-15B	FoC	Mon	CR- 22 RIMMS	04:00 PM	05:00 PM	Lec	Makeup	2026-06-29		Alamdar Hussain	960	\N
3890	Dr. Ahmed Naeem	Digital Signal Processing	2K23-BEE-15D	ECE	Fri	CR-01	03:00 PM	04:00 PM	Lab	Makeup	2026-08-07		Alamdar Hussain	900	\N
\.


--
-- Name: attendance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attendance_id_seq', 1, true);


--
-- Name: exam_marks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.exam_marks_id_seq', 1, false);


--
-- Name: exam_weights_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.exam_weights_id_seq', 1, false);


--
-- Name: faculty_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.faculty_accounts_id_seq', 131, true);


--
-- Name: finance_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.finance_accounts_id_seq', 2, true);


--
-- Name: finance_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.finance_payments_id_seq', 1, false);


--
-- Name: finance_rates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.finance_rates_id_seq', 1, true);


--
-- Name: holidays_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.holidays_id_seq', 2, true);


--
-- Name: schedules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schedules_id_seq', 4, true);


--
-- Name: students_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.students_id_seq', 3, true);


--
-- Name: support_staff_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.support_staff_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 5, true);


--
-- Name: weekly_schedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.weekly_schedule_id_seq', 3890, true);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- Name: attendance attendance_schedule_id_class_name_date_session_time_roll_no_uni; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_schedule_id_class_name_date_session_time_roll_no_uni UNIQUE (schedule_id, class_name, date, session_time, roll_no);


--
-- Name: exam_marks exam_marks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam_marks
    ADD CONSTRAINT exam_marks_pkey PRIMARY KEY (id);


--
-- Name: exam_marks exam_marks_schedule_id_class_name_roll_no_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam_marks
    ADD CONSTRAINT exam_marks_schedule_id_class_name_roll_no_key UNIQUE (schedule_id, class_name, roll_no);


--
-- Name: exam_weights exam_weights_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam_weights
    ADD CONSTRAINT exam_weights_pkey PRIMARY KEY (id);


--
-- Name: exam_weights exam_weights_schedule_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam_weights
    ADD CONSTRAINT exam_weights_schedule_id_key UNIQUE (schedule_id);


--
-- Name: faculty_accounts faculty_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faculty_accounts
    ADD CONSTRAINT faculty_accounts_pkey PRIMARY KEY (id);


--
-- Name: faculty_accounts faculty_accounts_schedule_id_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faculty_accounts
    ADD CONSTRAINT faculty_accounts_schedule_id_username_key UNIQUE (schedule_id, username);


--
-- Name: finance_accounts finance_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finance_accounts
    ADD CONSTRAINT finance_accounts_pkey PRIMARY KEY (id);


--
-- Name: finance_accounts finance_accounts_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finance_accounts
    ADD CONSTRAINT finance_accounts_username_key UNIQUE (username);


--
-- Name: finance_payments finance_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finance_payments
    ADD CONSTRAINT finance_payments_pkey PRIMARY KEY (id);


--
-- Name: finance_rates finance_rates_person_type_person_id_schedule_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finance_rates
    ADD CONSTRAINT finance_rates_person_type_person_id_schedule_id_key UNIQUE (person_type, person_id, schedule_id);


--
-- Name: finance_rates finance_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finance_rates
    ADD CONSTRAINT finance_rates_pkey PRIMARY KEY (id);


--
-- Name: holidays holidays_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.holidays
    ADD CONSTRAINT holidays_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: students students_schedule_id_class_name_roll_no_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_schedule_id_class_name_roll_no_unique UNIQUE (schedule_id, class_name, roll_no);


--
-- Name: support_staff support_staff_employee_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_staff
    ADD CONSTRAINT support_staff_employee_id_key UNIQUE (employee_id);


--
-- Name: support_staff support_staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_staff
    ADD CONSTRAINT support_staff_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_unique UNIQUE (username);


--
-- Name: weekly_schedule weekly_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_schedule
    ADD CONSTRAINT weekly_schedule_pkey PRIMARY KEY (id);


--
-- Name: faculty_accounts faculty_accounts_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faculty_accounts
    ADD CONSTRAINT faculty_accounts_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.schedules(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict OhMSjcfoYeQlEOe1Q3NAiFRzGhz5OzJ447NmhYoA0kOpw19TbtoyhHgoq2cc0pX

