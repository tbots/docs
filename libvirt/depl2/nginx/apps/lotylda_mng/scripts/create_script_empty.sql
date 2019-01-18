--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.1
-- Dumped by pg_dump version 9.4.6
-- Started on 2016-02-29 15:52:29 CET

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 14 (class 2615 OID 778695)
-- Name: attrcache; Type: SCHEMA; Schema: -; Owner: lotylda_admin
--

CREATE SCHEMA attrcache;


ALTER SCHEMA attrcache OWNER TO lotylda_admin;

--
-- TOC entry 13 (class 2615 OID 778694)
-- Name: datastore; Type: SCHEMA; Schema: -; Owner: lotylda_admin
--

CREATE SCHEMA datastore;


ALTER SCHEMA datastore OWNER TO lotylda_admin;

--
-- TOC entry 17 (class 2615 OID 778698)
-- Name: datetime_cols; Type: SCHEMA; Schema: -; Owner: lotylda_admin
--

CREATE SCHEMA datetime_cols;


ALTER SCHEMA datetime_cols OWNER TO lotylda_admin;

--
-- TOC entry 9 (class 2615 OID 741605)
-- Name: engine; Type: SCHEMA; Schema: -; Owner: lotylda_admin
--

CREATE SCHEMA engine;


ALTER SCHEMA engine OWNER TO lotylda_admin;

--
-- TOC entry 10 (class 2615 OID 741606)
-- Name: maintenance; Type: SCHEMA; Schema: -; Owner: lotylda_admin
--

CREATE SCHEMA maintenance;


ALTER SCHEMA maintenance OWNER TO lotylda_admin;

--
-- TOC entry 15 (class 2615 OID 778696)
-- Name: repcache; Type: SCHEMA; Schema: -; Owner: lotylda_admin
--

CREATE SCHEMA repcache;


ALTER SCHEMA repcache OWNER TO lotylda_admin;

--
-- TOC entry 16 (class 2615 OID 778697)
-- Name: temp; Type: SCHEMA; Schema: -; Owner: lotylda_admin
--

CREATE SCHEMA temp;


ALTER SCHEMA temp OWNER TO lotylda_admin;

--
-- TOC entry 11 (class 2615 OID 741608)
-- Name: userspace; Type: SCHEMA; Schema: -; Owner: lotylda_admin
--

CREATE SCHEMA userspace;


ALTER SCHEMA userspace OWNER TO lotylda_admin;

--
-- TOC entry 1 (class 3079 OID 12723)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 3 (class 3079 OID 741609)
-- Name: plr; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plr WITH SCHEMA public;


--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION plr; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plr IS 'load R interpreter and execute R script from within a database';


--
-- TOC entry 2 (class 3079 OID 741635)
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


SET search_path = public, pg_catalog;

--
-- TOC entry 296 (class 1255 OID 741639)
-- Name: fdnorm(double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION fdnorm(double precision, double precision, double precision) RETURNS double precision
    LANGUAGE plr IMMUTABLE STRICT
    AS $$
    
    return(dnorm(arg1,mean=arg2, arg3))
    
$$;


ALTER FUNCTION public.fdnorm(double precision, double precision, double precision) OWNER TO lotylda_admin;

--
-- TOC entry 297 (class 1255 OID 741640)
-- Name: first_day(date); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION first_day(date) RETURNS date
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$  SELECT (date_trunc('MONTH', $1))::date;$_$;


ALTER FUNCTION public.first_day(date) OWNER TO lotylda_admin;

--
-- TOC entry 298 (class 1255 OID 741647)
-- Name: get_ds_by_tbl(character varying); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION get_ds_by_tbl(character varying) RETURNS character varying
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$  select distinct ds.dataset_id from engine.data_tbls tbls inner join engine.data_cols dc on tbls.tbl_id = dc.tbl_id inner join engine.attributes attrs on attrs.col_val_id = dc.col_id inner join engine.datasets ds on ds.dataset_id = attrs.dataset_id where tbls.tbl_id = $1 and ds.dataset_type_id != 4$_$;


ALTER FUNCTION public.get_ds_by_tbl(character varying) OWNER TO lotylda_admin;

--
-- TOC entry 299 (class 1255 OID 741651)
-- Name: get_ds_type_by_tbl(character varying); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION get_ds_type_by_tbl(character varying) RETURNS character varying
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$  select distinct dt.dataset_type_descr from engine.data_tbls tbls 
inner join engine.data_cols dc on tbls.tbl_id = dc.tbl_id 
inner join engine.attributes attrs on attrs.col_val_id = dc.col_id 
inner join engine.datasets ds on ds.dataset_id = attrs.dataset_id 
inner join engine.dataset_type dt on dt.dataset_type_id = ds.dataset_type_id 
where tbls.tbl_id = $1 $_$;


ALTER FUNCTION public.get_ds_type_by_tbl(character varying) OWNER TO lotylda_admin;

--
-- TOC entry 300 (class 1255 OID 741652)
-- Name: insert_date_int(); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION insert_date_int() RETURNS trigger
    LANGUAGE plpgsql STRICT
    AS $$

  BEGIN
  
  EXECUTE ' UPDATE ' || TG_ARGV[0] || ' SET ' || TG_ARGV[2] || ' = EXTRACT(YEAR from ' || TG_ARGV[1] || '::date) * 10000 + EXTRACT(MONTH from ' || TG_ARGV[1] || '::date) * 100 + EXTRACT(DAY from ' || TG_ARGV[1] || '::date)
        WHERE ' || TG_ARGV[1] || ' IS NOT NULL AND ' || TG_ARGV[2] || ' IS NULL';
RETURN NEW;
end;
    
 $$;


ALTER FUNCTION public.insert_date_int() OWNER TO lotylda_admin;

--
-- TOC entry 301 (class 1255 OID 741653)
-- Name: insert_td_date_int(); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION insert_td_date_int() RETURNS trigger
    LANGUAGE plpgsql STRICT
    AS $$

  BEGIN
  
  EXECUTE ' INSERT INTO ' || TG_ARGV[0] || ' SELECT  extract(year from date_col::date)*10000 + extract(month from date_col::date)*100 + extract(day from date_col::date),
	    extract(year from date_col::date), 
            extract(quarter from date_col::date), 
            extract(month from date_col::date), 
	    extract(week from date_col::date), 
	    extract(doy from date_col::date), 
            null, 
            extract(day from date_col::date), 
            extract(isodow from date_col::date), 
	    null,
            extract(year from date_col::date)*10 + extract(quarter from date_col::date),
            extract(year from date_col::date)*100 + extract(month from date_col::date), 
            extract(year from date_col::date)*100 + extract(week from date_col::date)
    FROM ( SELECT DISTINCT ' || TG_ARGV[2] || '::date as  date_col FROM ' || TG_ARGV[1] || ') a';
RETURN NEW;
end;
    
 $$;


ALTER FUNCTION public.insert_td_date_int() OWNER TO lotylda_admin;

--
-- TOC entry 302 (class 1255 OID 741654)
-- Name: insert_time_int(); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION insert_time_int() RETURNS trigger
    LANGUAGE plpgsql STRICT
    AS $$

  BEGIN
  
  EXECUTE ' UPDATE ' || TG_ARGV[0] || ' SET ' || TG_ARGV[2] || ' = 1000000 + EXTRACT(HOUR from ' || TG_ARGV[1] || ') * 10000  + EXTRACT(MINUTE from ' || TG_ARGV[1] || ') * 100 + EXTRACT(SECOND from ' || TG_ARGV[1] || ')

        WHERE ' || TG_ARGV[1] || ' IS NOT NULL AND ' || TG_ARGV[2] || ' IS NULL';
RETURN NEW;
end;
    
 $$;


ALTER FUNCTION public.insert_time_int() OWNER TO lotylda_admin;

--
-- TOC entry 303 (class 1255 OID 741655)
-- Name: last_day(date); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION last_day(date) RETURNS date
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$  SELECT (date_trunc('MONTH', $1) + INTERVAL '1 MONTH - 1 day')::date;$_$;


ALTER FUNCTION public.last_day(date) OWNER TO lotylda_admin;

--
-- TOC entry 304 (class 1255 OID 741656)
-- Name: last_days(integer); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION last_days(integer) RETURNS date
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$  SELECT (now()::date - ($1::text || 'day')::interval)::date;$_$;


ALTER FUNCTION public.last_days(integer) OWNER TO lotylda_admin;

--
-- TOC entry 305 (class 1255 OID 741657)
-- Name: last_months(integer); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION last_months(integer) RETURNS date
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$  SELECT (now()::date - ($1::text || 'month')::interval)::date;$_$;


ALTER FUNCTION public.last_months(integer) OWNER TO lotylda_admin;

--
-- TOC entry 306 (class 1255 OID 741658)
-- Name: last_weeks(integer); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION last_weeks(integer) RETURNS date
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$  SELECT (now()::date - ($1::text || 'week')::interval)::date;$_$;


ALTER FUNCTION public.last_weeks(integer) OWNER TO lotylda_admin;

--
-- TOC entry 307 (class 1255 OID 741659)
-- Name: last_years(integer); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION last_years(integer) RETURNS date
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$  SELECT (now()::date - ($1::text || 'year')::interval)::date;$_$;


ALTER FUNCTION public.last_years(integer) OWNER TO lotylda_admin;

--
-- TOC entry 308 (class 1255 OID 741660)
-- Name: r_dnorm(double precision[]); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION r_dnorm(double precision[]) RETURNS json
    LANGUAGE plr IMMUTABLE STRICT
    AS $$
    library(jsonlite)
    X = arg1
    y = dnorm(X,mean=mean(X), sd(X))
    l = length(X)
    step = floor(l/50)
    xx = X[seq(1,l,step)]
    yy = y[seq(1,l,step)]
    return(toJSON(t(rbind(xx,yy))))
    
$$;


ALTER FUNCTION public.r_dnorm(double precision[]) OWNER TO lotylda_admin;

--
-- TOC entry 309 (class 1255 OID 741661)
-- Name: r_dnorm2(double precision[]); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION r_dnorm2(double precision[]) RETURNS json
    LANGUAGE plr STRICT
    AS $$
    library(jsonlite)
    X = arg1
    y = dnorm(X,mean=mean(X), sd(X))
    l = length(X)
    step = floor(l/50)
    xx = X[seq(1,l,step)]
    yy = y[seq(1,l,step)]
    return(toJSON(t(rbind(xx,yy))))
    
$$;


ALTER FUNCTION public.r_dnorm2(double precision[]) OWNER TO lotylda_admin;

--
-- TOC entry 310 (class 1255 OID 741662)
-- Name: r_dsplinenorm(double precision[]); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION r_dsplinenorm(double precision[]) RETURNS json
    LANGUAGE plr STRICT
    AS $_$
    library(jsonlite)
    X = arg1
    s = spline(dnorm(X,mean=mean(X), sd(X)))
    return(toJSON(t(rbind(s$x,s$y))))
    
$_$;


ALTER FUNCTION public.r_dsplinenorm(double precision[]) OWNER TO lotylda_admin;

--
-- TOC entry 311 (class 1255 OID 741663)
-- Name: update_date_tbl(); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION update_date_tbl() RETURNS trigger
    LANGUAGE plpgsql STRICT
    AS $$
  BEGIN

  EXECUTE 'UPDATE '||  TG_ARGV[13]  ||' SET  
        ' || TG_ARGV[1] || ' = extract(year from to_date( ' || TG_ARGV[0] || '::text, ''YYYYMMDD'')), 
            ' || TG_ARGV[2] || ' = extract(quarter from to_date( ' || TG_ARGV[0] || '::text, ''YYYYMMDD'')), 
            ' || TG_ARGV[3] || ' = extract(month from to_date( ' || TG_ARGV[0] || '::text, ''YYYYMMDD'')), 
        ' || TG_ARGV[4] || ' = extract(week from to_date( ' || TG_ARGV[0] || '::text, ''YYYYMMDD'')), 
        ' || TG_ARGV[5] || ' = extract(doy from to_date( ' || TG_ARGV[0] || '::text, ''YYYYMMDD'')), 
            ' || TG_ARGV[6] || ' = null, 
            ' || TG_ARGV[7] || ' = extract(day from to_date( ' || TG_ARGV[0] || '::text, ''YYYYMMDD'')), 
            ' || TG_ARGV[8] || ' = extract(isodow from to_date( ' || TG_ARGV[0] || '::text, ''YYYYMMDD'')), 
        ' || TG_ARGV[9] || ' = null,
            ' || TG_ARGV[10] || ' = extract(year from to_date( ' || TG_ARGV[0] || '::text, ''YYYYMMDD''))*10 + extract(quarter from to_date( ' || TG_ARGV[0] || '::text, ''YYYYMMDD'')),
            ' || TG_ARGV[11] || ' = extract(year from to_date( ' || TG_ARGV[0] || '::text, ''YYYYMMDD''))*100 + extract(month from to_date( ' || TG_ARGV[0] || '::text, ''YYYYMMDD'')), 
            ' || TG_ARGV[12] || ' = extract(year from to_date( ' || TG_ARGV[0] || '::text, ''YYYYMMDD''))*100 + extract(week from to_date( ' || TG_ARGV[0] || '::text, ''YYYYMMDD''))';
RETURN NEW;
end;
    
 $$;


ALTER FUNCTION public.update_date_tbl() OWNER TO lotylda_admin;

--
-- TOC entry 312 (class 1255 OID 741664)
-- Name: update_time_tbl(); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION update_time_tbl() RETURNS trigger
    LANGUAGE plpgsql STRICT
    AS $$
  BEGIN

  EXECUTE 'UPDATE '||  TG_ARGV[4]  ||' SET  
        ' || TG_ARGV[1] || ' = substring( ' || TG_ARGV[0] || '::text from 2 for 2)::int, 
            ' || TG_ARGV[2] || ' = substring( ' || TG_ARGV[0] || '::text from 4 for 2)::int, 
            ' || TG_ARGV[3] || ' = substring( ' || TG_ARGV[0] || '::text from 6 for 2)::int'; 
        
RETURN NEW;
end;
    
 $$;


ALTER FUNCTION public.update_time_tbl() OWNER TO lotylda_admin;

--
-- TOC entry 313 (class 1255 OID 741665)
-- Name: update_users(); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION update_users() RETURNS trigger
    LANGUAGE plpgsql STRICT
    AS $$

  BEGIN
  
  EXECUTE ' insert into userspace.users select user_id, 1, True, username from auth_user where user_id not in (select user_id from userspace.users) ';
RETURN NEW;
end;
$$;


ALTER FUNCTION public.update_users() OWNER TO lotylda_admin;

--
-- TOC entry 314 (class 1255 OID 741666)
-- Name: user_project_privilege(character varying); Type: FUNCTION; Schema: public; Owner: lotylda_admin
--

CREATE FUNCTION user_project_privilege(character varying) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$  SELECT CASE WHEN up.privilege_id != -1 THEN up.privilege_id	    WHEN ugp.privlege_id IS NOT NULL THEN ugp.privlege_id	    ELSE 4	    END  FROM (    SELECT user_id, privilege_id FROM userspace.users    WHERE user_id = $1  ) up   LEFT JOIN (    SELECT user_id, min(privilege_id) as privlege_id FROM userspace.usergroups     INNER JOIN userspace.usergroup_users USING(usergroup_id)    WHERE user_id = $1    GROUP BY user_id  ) ugp ON up.user_id = ugp.user_id;$_$;


ALTER FUNCTION public.user_project_privilege(character varying) OWNER TO lotylda_admin;

--
-- TOC entry 890 (class 1255 OID 741667)
-- Name: dnorm(double precision); Type: AGGREGATE; Schema: public; Owner: lotylda_admin
--

CREATE AGGREGATE dnorm(double precision) (
    SFUNC = plr_array_accum,
    STYPE = double precision[],
    FINALFUNC = r_dnorm
);


ALTER AGGREGATE public.dnorm(double precision) OWNER TO lotylda_admin;

--
-- TOC entry 891 (class 1255 OID 741668)
-- Name: dsplinenorm(double precision); Type: AGGREGATE; Schema: public; Owner: lotylda_admin
--

CREATE AGGREGATE dsplinenorm(double precision) (
    SFUNC = plr_array_accum,
    STYPE = double precision[],
    FINALFUNC = r_dsplinenorm
);


ALTER AGGREGATE public.dsplinenorm(double precision) OWNER TO lotylda_admin;

SET search_path = engine, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 186 (class 1259 OID 741732)
-- Name: attr_type; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE attr_type (
    attr_type_id smallint NOT NULL,
    attr_type_descr character varying(50)
);


ALTER TABLE attr_type OWNER TO lotylda_admin;

--
-- TOC entry 187 (class 1259 OID 741735)
-- Name: attributes; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE attributes (
    attr_id character varying(40) NOT NULL,
    attr_name character varying(100) NOT NULL,
    attr_type_id smallint NOT NULL,
    module_group_id character varying(50),
    col_val_id character varying(50) NOT NULL,
    col_name_id character varying(50),
    col_order_id character varying(50),
    dataset_id character varying(50) NOT NULL
);


ALTER TABLE attributes OWNER TO lotylda_admin;

--
-- TOC entry 188 (class 1259 OID 741741)
-- Name: col_datatype; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE col_datatype (
    col_datatype_id smallint NOT NULL,
    col_datatype_descr character varying(50),
    has_len boolean
);


ALTER TABLE col_datatype OWNER TO lotylda_admin;

--
-- TOC entry 189 (class 1259 OID 741744)
-- Name: col_type; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE col_type (
    col_type_id smallint NOT NULL,
    col_type_descr character varying(50),
    isdefault boolean
);


ALTER TABLE col_type OWNER TO lotylda_admin;

--
-- TOC entry 190 (class 1259 OID 741747)
-- Name: data_cols; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE data_cols (
    col_id character varying(50) NOT NULL,
    tbl_id character varying(100),
    col_name character varying(100),
    col_datatype_id smallint,
    col_type_id smallint,
    col_len character varying(10),
    date_type_id smallint
);


ALTER TABLE data_cols OWNER TO lotylda_admin;

--
-- TOC entry 191 (class 1259 OID 741750)
-- Name: data_tbls; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE data_tbls (
    tbl_id character varying(100) NOT NULL,
    tbl_name character varying(100),
    last_upload timestamp without time zone,
    upload_status json
);


ALTER TABLE data_tbls OWNER TO lotylda_admin;

--
-- TOC entry 192 (class 1259 OID 741756)
-- Name: data_tbls_rel_cols; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE data_tbls_rel_cols (
    tbl_id character varying(100) NOT NULL,
    col_id character varying(50) NOT NULL,
    parent_tbl_id character varying(100) NOT NULL,
    parent_col_id character varying(50) NOT NULL
);


ALTER TABLE data_tbls_rel_cols OWNER TO lotylda_admin;

--
-- TOC entry 193 (class 1259 OID 741759)
-- Name: dataset_type; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE dataset_type (
    dataset_type_id smallint NOT NULL,
    dataset_type_descr character varying(50),
    is_time_ds boolean
);


ALTER TABLE dataset_type OWNER TO lotylda_admin;

--
-- TOC entry 194 (class 1259 OID 741762)
-- Name: datasets; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE datasets (
    dataset_id character varying(50) NOT NULL,
    dataset_name character varying(100) NOT NULL,
    dataset_type_id smallint NOT NULL,
    created timestamp without time zone,
    modified timestamp without time zone,
    config_json json,
    config_json_backup json,
    last_upload timestamp without time zone,
    partitioned smallint DEFAULT (-1),
    is_created boolean DEFAULT false NOT NULL
);


ALTER TABLE datasets OWNER TO lotylda_admin;

--
-- TOC entry 195 (class 1259 OID 741770)
-- Name: denied_attribute_usergroups; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE denied_attribute_usergroups (
    attr_id character varying(50) NOT NULL,
    usergroup_id character varying(50) NOT NULL
);


ALTER TABLE denied_attribute_usergroups OWNER TO lotylda_admin;

--
-- TOC entry 196 (class 1259 OID 741773)
-- Name: denied_attribute_users; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE denied_attribute_users (
    attr_id character varying(50) NOT NULL,
    user_id character varying(50) NOT NULL
);


ALTER TABLE denied_attribute_users OWNER TO lotylda_admin;

--
-- TOC entry 197 (class 1259 OID 741776)
-- Name: denied_dataset_usergroups; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE denied_dataset_usergroups (
    dataset_id character varying(50) NOT NULL,
    usergroup_id character varying(50) NOT NULL
);


ALTER TABLE denied_dataset_usergroups OWNER TO lotylda_admin;

--
-- TOC entry 198 (class 1259 OID 741779)
-- Name: denied_dataset_users; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE denied_dataset_users (
    dataset_id character varying(50) NOT NULL,
    user_id character varying(50) NOT NULL
);


ALTER TABLE denied_dataset_users OWNER TO lotylda_admin;

--
-- TOC entry 199 (class 1259 OID 741788)
-- Name: filter_type; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE filter_type (
    filter_type_id smallint NOT NULL,
    filter_name text NOT NULL,
    formula text NOT NULL,
    attr_type_id smallint
);


ALTER TABLE filter_type OWNER TO lotylda_admin;

--
-- TOC entry 200 (class 1259 OID 741797)
-- Name: measures_groups; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE measures_groups (
    measures_group_id character varying(50) NOT NULL,
    measures_group_name character varying(100)
);


ALTER TABLE measures_groups OWNER TO lotylda_admin;

SET search_path = public, pg_catalog;

--
-- TOC entry 201 (class 1259 OID 741800)
-- Name: project_object_types_seq; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE project_object_types_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE project_object_types_seq OWNER TO lotylda_admin;

SET search_path = engine, pg_catalog;

--
-- TOC entry 202 (class 1259 OID 741802)
-- Name: object_types; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE object_types (
    object_type_id smallint DEFAULT nextval('public.project_object_types_seq'::regclass) NOT NULL,
    object_type_name character varying(50),
    object_type_descr character varying(100),
    object_type_prefix character varying(10)
);


ALTER TABLE object_types OWNER TO lotylda_admin;

--
-- TOC entry 203 (class 1259 OID 741806)
-- Name: time_date_definition; Type: TABLE; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE time_date_definition (
    td_id smallint NOT NULL,
    td_name character varying(50),
    td_descr character varying(50),
    td_data_type character varying(20),
    td_type smallint
);


ALTER TABLE time_date_definition OWNER TO lotylda_admin;

SET search_path = maintenance, pg_catalog;

--
-- TOC entry 204 (class 1259 OID 741812)
-- Name: data_integrity; Type: TABLE; Schema: maintenance; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE data_integrity (
    dati_id integer NOT NULL,
    created timestamp without time zone,
    result boolean,
    descr json
);


ALTER TABLE data_integrity OWNER TO lotylda_admin;

--
-- TOC entry 205 (class 1259 OID 741818)
-- Name: data_upload; Type: TABLE; Schema: maintenance; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE data_upload (
    up_id bigint NOT NULL,
    up_hash character varying(50) NOT NULL,
    up_start timestamp without time zone DEFAULT now() NOT NULL,
    up_end timestamp without time zone,
    up_result boolean,
    up_log jsonb
);


ALTER TABLE data_upload OWNER TO lotylda_admin;

--
-- TOC entry 206 (class 1259 OID 741825)
-- Name: data_upload_up_id_seq; Type: SEQUENCE; Schema: maintenance; Owner: lotylda_admin
--

CREATE SEQUENCE data_upload_up_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE data_upload_up_id_seq OWNER TO lotylda_admin;

--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 206
-- Name: data_upload_up_id_seq; Type: SEQUENCE OWNED BY; Schema: maintenance; Owner: lotylda_admin
--

ALTER SEQUENCE data_upload_up_id_seq OWNED BY data_upload.up_id;


SET search_path = public, pg_catalog;

--
-- TOC entry 207 (class 1259 OID 741827)
-- Name: auth_cas; Type: TABLE; Schema: public; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE auth_cas (
    id integer NOT NULL,
    user_id integer,
    created_on timestamp without time zone,
    service character varying(512),
    ticket character varying(512),
    renew character(1)
);


ALTER TABLE auth_cas OWNER TO lotylda_admin;

--
-- TOC entry 208 (class 1259 OID 741833)
-- Name: auth_cas_id_seq; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE auth_cas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_cas_id_seq OWNER TO lotylda_admin;

--
-- TOC entry 209 (class 1259 OID 741835)
-- Name: auth_cas_id_seq1; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE auth_cas_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_cas_id_seq1 OWNER TO lotylda_admin;

--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 209
-- Name: auth_cas_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: lotylda_admin
--

ALTER SEQUENCE auth_cas_id_seq1 OWNED BY auth_cas.id;


--
-- TOC entry 210 (class 1259 OID 741837)
-- Name: auth_event; Type: TABLE; Schema: public; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE auth_event (
    id integer NOT NULL,
    time_stamp timestamp without time zone,
    client_ip character varying(512),
    user_id integer,
    origin character varying(512),
    description text
);


ALTER TABLE auth_event OWNER TO lotylda_admin;

--
-- TOC entry 211 (class 1259 OID 741843)
-- Name: auth_event_id_seq; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE auth_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_event_id_seq OWNER TO lotylda_admin;

--
-- TOC entry 212 (class 1259 OID 741845)
-- Name: auth_event_id_seq1; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE auth_event_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_event_id_seq1 OWNER TO lotylda_admin;

--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 212
-- Name: auth_event_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: lotylda_admin
--

ALTER SEQUENCE auth_event_id_seq1 OWNED BY auth_event.id;


--
-- TOC entry 213 (class 1259 OID 741847)
-- Name: auth_group; Type: TABLE; Schema: public; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE auth_group (
    id integer NOT NULL,
    role character varying(512),
    description text
);


ALTER TABLE auth_group OWNER TO lotylda_admin;

--
-- TOC entry 214 (class 1259 OID 741853)
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_group_id_seq OWNER TO lotylda_admin;

--
-- TOC entry 215 (class 1259 OID 741855)
-- Name: auth_group_id_seq1; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE auth_group_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_group_id_seq1 OWNER TO lotylda_admin;

--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 215
-- Name: auth_group_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: lotylda_admin
--

ALTER SEQUENCE auth_group_id_seq1 OWNED BY auth_group.id;


--
-- TOC entry 216 (class 1259 OID 741857)
-- Name: auth_membership; Type: TABLE; Schema: public; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE auth_membership (
    id integer NOT NULL,
    user_id integer,
    group_id integer
);


ALTER TABLE auth_membership OWNER TO lotylda_admin;

--
-- TOC entry 217 (class 1259 OID 741866)
-- Name: auth_membership_id_seq; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE auth_membership_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_membership_id_seq OWNER TO lotylda_admin;

--
-- TOC entry 218 (class 1259 OID 741871)
-- Name: auth_membership_id_seq1; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE auth_membership_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_membership_id_seq1 OWNER TO lotylda_admin;

--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 218
-- Name: auth_membership_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: lotylda_admin
--

ALTER SEQUENCE auth_membership_id_seq1 OWNED BY auth_membership.id;


--
-- TOC entry 219 (class 1259 OID 741873)
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE auth_permission (
    id integer NOT NULL,
    group_id integer,
    name character varying(512),
    table_name character varying(512),
    record_id integer
);


ALTER TABLE auth_permission OWNER TO lotylda_admin;

--
-- TOC entry 220 (class 1259 OID 741879)
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_permission_id_seq OWNER TO lotylda_admin;

--
-- TOC entry 221 (class 1259 OID 741881)
-- Name: auth_permission_id_seq1; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE auth_permission_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_permission_id_seq1 OWNER TO lotylda_admin;

--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 221
-- Name: auth_permission_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: lotylda_admin
--

ALTER SEQUENCE auth_permission_id_seq1 OWNED BY auth_permission.id;


--
-- TOC entry 222 (class 1259 OID 741883)
-- Name: auth_user; Type: TABLE; Schema: public; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE auth_user (
    id integer NOT NULL,
    first_name character varying(128),
    last_name character varying(128),
    email character varying(512),
    username character varying(128),
    password character varying(512),
    registration_key character varying(512),
    reset_password_key character varying(512),
    registration_id character varying(512),
    user_id character varying(32),
    active character(1)
);


ALTER TABLE auth_user OWNER TO lotylda_admin;

--
-- TOC entry 223 (class 1259 OID 741889)
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_user_id_seq OWNER TO lotylda_admin;

--
-- TOC entry 224 (class 1259 OID 741891)
-- Name: auth_user_id_seq1; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE auth_user_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_user_id_seq1 OWNER TO lotylda_admin;

--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 224
-- Name: auth_user_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: lotylda_admin
--

ALTER SEQUENCE auth_user_id_seq1 OWNED BY auth_user.id;


--
-- TOC entry 225 (class 1259 OID 741980)
-- Name: scheduler_run; Type: TABLE; Schema: public; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE scheduler_run (
    id integer NOT NULL,
    task_id integer,
    status character varying(512),
    start_time timestamp without time zone,
    stop_time timestamp without time zone,
    run_output text,
    run_result text,
    traceback text,
    worker_name character varying(512)
);


ALTER TABLE scheduler_run OWNER TO lotylda_admin;

--
-- TOC entry 226 (class 1259 OID 741986)
-- Name: scheduler_run_id_seq; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE scheduler_run_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE scheduler_run_id_seq OWNER TO lotylda_admin;

--
-- TOC entry 227 (class 1259 OID 741988)
-- Name: scheduler_run_id_seq1; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE scheduler_run_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE scheduler_run_id_seq1 OWNER TO lotylda_admin;

--
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 227
-- Name: scheduler_run_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: lotylda_admin
--

ALTER SEQUENCE scheduler_run_id_seq1 OWNED BY scheduler_run.id;


--
-- TOC entry 228 (class 1259 OID 741990)
-- Name: scheduler_task; Type: TABLE; Schema: public; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE scheduler_task (
    id integer NOT NULL,
    application_name character varying(512),
    task_name character varying(512),
    group_name character varying(512),
    status character varying(512),
    function_name character varying(512),
    uuid character varying(255),
    args text,
    vars text,
    enabled character(1),
    start_time timestamp without time zone,
    next_run_time timestamp without time zone,
    stop_time timestamp without time zone,
    repeats integer,
    retry_failed integer,
    period integer,
    prevent_drift character(1),
    timeout integer,
    sync_output integer,
    times_run integer,
    times_failed integer,
    last_run_time timestamp without time zone,
    assigned_worker_name character varying(512)
);


ALTER TABLE scheduler_task OWNER TO lotylda_admin;

--
-- TOC entry 229 (class 1259 OID 741996)
-- Name: scheduler_task_deps; Type: TABLE; Schema: public; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE scheduler_task_deps (
    id integer NOT NULL,
    job_name character varying(512),
    task_parent integer,
    task_child integer,
    can_visit character(1)
);


ALTER TABLE scheduler_task_deps OWNER TO lotylda_admin;

--
-- TOC entry 230 (class 1259 OID 742002)
-- Name: scheduler_task_deps_id_seq; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE scheduler_task_deps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE scheduler_task_deps_id_seq OWNER TO lotylda_admin;

--
-- TOC entry 231 (class 1259 OID 742004)
-- Name: scheduler_task_deps_id_seq1; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE scheduler_task_deps_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE scheduler_task_deps_id_seq1 OWNER TO lotylda_admin;

--
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 231
-- Name: scheduler_task_deps_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: lotylda_admin
--

ALTER SEQUENCE scheduler_task_deps_id_seq1 OWNED BY scheduler_task_deps.id;


--
-- TOC entry 232 (class 1259 OID 742006)
-- Name: scheduler_task_id_seq; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE scheduler_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE scheduler_task_id_seq OWNER TO lotylda_admin;

--
-- TOC entry 233 (class 1259 OID 742008)
-- Name: scheduler_task_id_seq1; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE scheduler_task_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE scheduler_task_id_seq1 OWNER TO lotylda_admin;

--
-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 233
-- Name: scheduler_task_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: lotylda_admin
--

ALTER SEQUENCE scheduler_task_id_seq1 OWNED BY scheduler_task.id;


--
-- TOC entry 234 (class 1259 OID 742010)
-- Name: scheduler_worker; Type: TABLE; Schema: public; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE scheduler_worker (
    id integer NOT NULL,
    worker_name character varying(255),
    first_heartbeat timestamp without time zone,
    last_heartbeat timestamp without time zone,
    status character varying(512),
    is_ticker character(1),
    group_names text,
    worker_stats json
);


ALTER TABLE scheduler_worker OWNER TO lotylda_admin;

--
-- TOC entry 235 (class 1259 OID 742016)
-- Name: scheduler_worker_id_seq; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE scheduler_worker_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE scheduler_worker_id_seq OWNER TO lotylda_admin;

--
-- TOC entry 236 (class 1259 OID 742018)
-- Name: scheduler_worker_id_seq1; Type: SEQUENCE; Schema: public; Owner: lotylda_admin
--

CREATE SEQUENCE scheduler_worker_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE scheduler_worker_id_seq1 OWNER TO lotylda_admin;

--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 236
-- Name: scheduler_worker_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: lotylda_admin
--

ALTER SEQUENCE scheduler_worker_id_seq1 OWNED BY scheduler_worker.id;


SET search_path = userspace, pg_catalog;

--
-- TOC entry 237 (class 1259 OID 742029)
-- Name: dashboard_filters; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE dashboard_filters (
    dashboard_filter_id character varying(50) NOT NULL,
    dashboard_id character varying(50),
    filter_json json,
    html_config json
);


ALTER TABLE dashboard_filters OWNER TO lotylda_admin;

--
-- TOC entry 238 (class 1259 OID 742035)
-- Name: dashboard_report_filters; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE dashboard_report_filters (
    report_id character varying(50) NOT NULL,
    dashboard_filter_id character varying(50) NOT NULL
);


ALTER TABLE dashboard_report_filters OWNER TO lotylda_admin;

--
-- TOC entry 239 (class 1259 OID 742038)
-- Name: dashboard_reports; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE dashboard_reports (
    dashboard_id character varying(50) NOT NULL,
    report_id character varying(50) NOT NULL,
    coord_num integer NOT NULL,
    filter_json json,
    repcache timestamp without time zone
);


ALTER TABLE dashboard_reports OWNER TO lotylda_admin;

--
-- TOC entry 240 (class 1259 OID 742044)
-- Name: dashboard_user_groups; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE dashboard_user_groups (
    dashboard_id character varying(50) NOT NULL,
    usergroup_id character varying(50) NOT NULL,
    privilege_id smallint
);


ALTER TABLE dashboard_user_groups OWNER TO lotylda_admin;

--
-- TOC entry 241 (class 1259 OID 742047)
-- Name: dashboard_users; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE dashboard_users (
    user_id character varying(50) NOT NULL,
    privilege_id smallint,
    dashboard_id character varying(50) NOT NULL
);


ALTER TABLE dashboard_users OWNER TO lotylda_admin;

--
-- TOC entry 242 (class 1259 OID 742056)
-- Name: dashboards; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE dashboards (
    dashboard_id character varying(50) NOT NULL,
    dashboard_name character varying(100) NOT NULL,
    dashboards_descr text,
    created timestamp without time zone DEFAULT now(),
    created_user character varying(50),
    modified timestamp without time zone DEFAULT now(),
    modified_user character varying(50),
    config_json json,
    status_id smallint DEFAULT 1,
    module_group_id character varying(50) DEFAULT md5('default-unsorted'::text)
);


ALTER TABLE dashboards OWNER TO lotylda_admin;

--
-- TOC entry 243 (class 1259 OID 742069)
-- Name: denied_object_usergroups; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE denied_object_usergroups (
    object_id character varying(50) NOT NULL,
    usergroup_id character varying(50) NOT NULL,
    object_type_id smallint,
    privilege_id smallint
);


ALTER TABLE denied_object_usergroups OWNER TO lotylda_admin;

--
-- TOC entry 244 (class 1259 OID 742072)
-- Name: denied_object_users; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE denied_object_users (
    object_id character varying(50) NOT NULL,
    user_id character varying(50) NOT NULL,
    object_type_id smallint,
    privilege_id smallint
);


ALTER TABLE denied_object_users OWNER TO lotylda_admin;

--
-- TOC entry 245 (class 1259 OID 742075)
-- Name: measure_user_groups; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE measure_user_groups (
    measure_id character varying(50) NOT NULL,
    usergroup_id character varying(50) NOT NULL,
    privilege_id smallint
);


ALTER TABLE measure_user_groups OWNER TO lotylda_admin;

--
-- TOC entry 246 (class 1259 OID 742078)
-- Name: measure_users; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE measure_users (
    measure_id character varying(50) NOT NULL,
    user_id character varying(50) NOT NULL,
    privilege_id smallint
);


ALTER TABLE measure_users OWNER TO lotylda_admin;

--
-- TOC entry 247 (class 1259 OID 742081)
-- Name: measures; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE measures (
    measure_id character varying(50) NOT NULL,
    measure_name character varying(100),
    measure_descr text,
    measure_tables character varying(50)[],
    formula text,
    format character varying(255),
    created timestamp without time zone DEFAULT now(),
    created_user character varying(50),
    modified timestamp without time zone DEFAULT now(),
    modified_user character varying(50),
    module_group_id character varying(50) DEFAULT md5('default-unsorted'::text),
    formula_html text,
    report_id character varying(50),
    parent_measures character varying(50)[] DEFAULT '{}'::character varying[]
);


ALTER TABLE measures OWNER TO lotylda_admin;

--
-- TOC entry 248 (class 1259 OID 742091)
-- Name: module_groups; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE module_groups (
    module_group_id character varying(50) NOT NULL,
    module_group_name character varying(100),
    module_group_descr character varying(100),
    module_measures boolean DEFAULT true NOT NULL,
    module_reports boolean DEFAULT true NOT NULL,
    module_dashboards boolean DEFAULT true NOT NULL,
    module_attributes boolean DEFAULT true NOT NULL
);


ALTER TABLE module_groups OWNER TO lotylda_admin;

--
-- TOC entry 249 (class 1259 OID 742098)
-- Name: notes; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE notes (
    note_id character varying(50) NOT NULL,
    dashboard_id character varying(50),
    user_id character varying(50),
    config_json json
);


ALTER TABLE notes OWNER TO lotylda_admin;

--
-- TOC entry 250 (class 1259 OID 742104)
-- Name: privileges; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE privileges (
    privilege_id smallint NOT NULL,
    privilege_descr character varying(64),
    privilege_name character varying(50)
);


ALTER TABLE privileges OWNER TO lotylda_admin;

--
-- TOC entry 251 (class 1259 OID 742107)
-- Name: repcache_report; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE repcache_report (
    repcache_id character varying(50) NOT NULL,
    report_id character varying(50) NOT NULL
);


ALTER TABLE repcache_report OWNER TO lotylda_admin;

--
-- TOC entry 252 (class 1259 OID 742110)
-- Name: repcache_status; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE repcache_status (
    status_id integer NOT NULL,
    status_name character varying(50)
);


ALTER TABLE repcache_status OWNER TO lotylda_admin;

--
-- TOC entry 253 (class 1259 OID 742113)
-- Name: repcaches; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE repcaches (
    repcache_id character varying(50) NOT NULL,
    created timestamp without time zone DEFAULT now(),
    last_call timestamp without time zone,
    status_id integer,
    lolaq text,
    valid_until timestamp without time zone,
    next_refresh timestamp without time zone,
    error_info text
);


ALTER TABLE repcaches OWNER TO lotylda_admin;

--
-- TOC entry 254 (class 1259 OID 742120)
-- Name: report_comments; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE report_comments (
    report_id character varying(50) NOT NULL,
    report_comment_id bigint NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    created_user character varying(50) NOT NULL,
    report_comment text NOT NULL
);


ALTER TABLE report_comments OWNER TO lotylda_admin;

--
-- TOC entry 255 (class 1259 OID 742127)
-- Name: report_comments_report_comment_id_seq; Type: SEQUENCE; Schema: userspace; Owner: lotylda_admin
--

CREATE SEQUENCE report_comments_report_comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE report_comments_report_comment_id_seq OWNER TO lotylda_admin;

--
-- TOC entry 3595 (class 0 OID 0)
-- Dependencies: 255
-- Name: report_comments_report_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: userspace; Owner: lotylda_admin
--

ALTER SEQUENCE report_comments_report_comment_id_seq OWNED BY report_comments.report_comment_id;


--
-- TOC entry 256 (class 1259 OID 742129)
-- Name: report_notes; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE report_notes (
    report_note_id character varying(50) NOT NULL,
    report_id character varying(50),
    user_id character varying(50),
    config_json json,
    dashboard_id character varying(50)
);


ALTER TABLE report_notes OWNER TO lotylda_admin;

--
-- TOC entry 257 (class 1259 OID 742135)
-- Name: report_user_groups; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE report_user_groups (
    report_id character varying(50) NOT NULL,
    usergroup_id character varying(50) NOT NULL,
    privilege_id smallint NOT NULL,
    context_filter json
);


ALTER TABLE report_user_groups OWNER TO lotylda_admin;

--
-- TOC entry 258 (class 1259 OID 742141)
-- Name: report_users; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE report_users (
    report_id character varying(50) NOT NULL,
    user_id character varying(50) NOT NULL,
    privilege_id smallint NOT NULL,
    context_filter json
);


ALTER TABLE report_users OWNER TO lotylda_admin;

--
-- TOC entry 259 (class 1259 OID 742156)
-- Name: reports; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE reports (
    report_id character varying(50) NOT NULL,
    report_name character varying(100) NOT NULL,
    report_descr text,
    created timestamp without time zone DEFAULT now(),
    created_user character varying(50),
    modified timestamp without time zone DEFAULT now(),
    modified_user character varying(50),
    config_json json,
    option_json json,
    module_group_id character varying(50) DEFAULT md5('default-unsorted'::text),
    status_id smallint DEFAULT 1,
    repcache json,
    cache_enabled boolean DEFAULT true,
    cache_json json,
    edit_json json
);


ALTER TABLE reports OWNER TO lotylda_admin;

--
-- TOC entry 260 (class 1259 OID 742167)
-- Name: status; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE status (
    status_id smallint NOT NULL,
    status_descr character varying(50) NOT NULL
);


ALTER TABLE status OWNER TO lotylda_admin;

--
-- TOC entry 261 (class 1259 OID 742170)
-- Name: user_filter_cache; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE user_filter_cache (
    user_filter_cache_id character varying(50) NOT NULL,
    user_id character varying(50),
    report_id character varying(50),
    dashboard_id character varying(50),
    cache_type_id integer,
    cache_json json
);


ALTER TABLE user_filter_cache OWNER TO lotylda_admin;

--
-- TOC entry 262 (class 1259 OID 742176)
-- Name: user_filter_cache_type; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE user_filter_cache_type (
    cache_type_id integer NOT NULL,
    cache_type_descr character varying(50)
);


ALTER TABLE user_filter_cache_type OWNER TO lotylda_admin;

--
-- TOC entry 263 (class 1259 OID 742179)
-- Name: user_tabs; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE user_tabs (
    user_tab_id character varying(50) NOT NULL,
    user_id character varying(50),
    tab_name character varying(100),
    report_id character varying(50) DEFAULT 'empty'::character varying,
    dashboard_id character varying(50) DEFAULT 'empty'::character varying,
    tab_index smallint DEFAULT 0
);


ALTER TABLE user_tabs OWNER TO lotylda_admin;

--
-- TOC entry 264 (class 1259 OID 742185)
-- Name: usergroup_users; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE usergroup_users (
    usergroup_id character varying(50) NOT NULL,
    user_id character varying(50) NOT NULL
);


ALTER TABLE usergroup_users OWNER TO lotylda_admin;

--
-- TOC entry 265 (class 1259 OID 742188)
-- Name: usergroups; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE usergroups (
    usergroup_id character varying(50) NOT NULL,
    usergroup_name character varying(100),
    usergroup_descr character varying(255),
    privilege_id smallint,
    datafilter text
);


ALTER TABLE usergroups OWNER TO lotylda_admin;

--
-- TOC entry 266 (class 1259 OID 742194)
-- Name: users; Type: TABLE; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE TABLE users (
    user_id character varying(50) NOT NULL,
    privilege_id smallint DEFAULT (-1) NOT NULL,
    project_admin boolean DEFAULT false NOT NULL,
    username character varying(128),
    datafilter text
);


ALTER TABLE users OWNER TO lotylda_admin;

SET search_path = maintenance, pg_catalog;

--
-- TOC entry 3113 (class 2604 OID 742202)
-- Name: up_id; Type: DEFAULT; Schema: maintenance; Owner: lotylda_admin
--

ALTER TABLE ONLY data_upload ALTER COLUMN up_id SET DEFAULT nextval('data_upload_up_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- TOC entry 3114 (class 2604 OID 742203)
-- Name: id; Type: DEFAULT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY auth_cas ALTER COLUMN id SET DEFAULT nextval('auth_cas_id_seq1'::regclass);


--
-- TOC entry 3115 (class 2604 OID 742204)
-- Name: id; Type: DEFAULT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY auth_event ALTER COLUMN id SET DEFAULT nextval('auth_event_id_seq1'::regclass);


--
-- TOC entry 3116 (class 2604 OID 742205)
-- Name: id; Type: DEFAULT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY auth_group ALTER COLUMN id SET DEFAULT nextval('auth_group_id_seq1'::regclass);


--
-- TOC entry 3117 (class 2604 OID 742206)
-- Name: id; Type: DEFAULT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY auth_membership ALTER COLUMN id SET DEFAULT nextval('auth_membership_id_seq1'::regclass);


--
-- TOC entry 3118 (class 2604 OID 742207)
-- Name: id; Type: DEFAULT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY auth_permission ALTER COLUMN id SET DEFAULT nextval('auth_permission_id_seq1'::regclass);


--
-- TOC entry 3119 (class 2604 OID 742208)
-- Name: id; Type: DEFAULT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY auth_user ALTER COLUMN id SET DEFAULT nextval('auth_user_id_seq1'::regclass);


--
-- TOC entry 3120 (class 2604 OID 742209)
-- Name: id; Type: DEFAULT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY scheduler_run ALTER COLUMN id SET DEFAULT nextval('scheduler_run_id_seq1'::regclass);


--
-- TOC entry 3121 (class 2604 OID 742210)
-- Name: id; Type: DEFAULT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY scheduler_task ALTER COLUMN id SET DEFAULT nextval('scheduler_task_id_seq1'::regclass);


--
-- TOC entry 3122 (class 2604 OID 742211)
-- Name: id; Type: DEFAULT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY scheduler_task_deps ALTER COLUMN id SET DEFAULT nextval('scheduler_task_deps_id_seq1'::regclass);


--
-- TOC entry 3123 (class 2604 OID 742212)
-- Name: id; Type: DEFAULT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY scheduler_worker ALTER COLUMN id SET DEFAULT nextval('scheduler_worker_id_seq1'::regclass);


SET search_path = userspace, pg_catalog;

--
-- TOC entry 3138 (class 2604 OID 742213)
-- Name: report_comment_id; Type: DEFAULT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY report_comments ALTER COLUMN report_comment_id SET DEFAULT nextval('report_comments_report_comment_id_seq'::regclass);


SET search_path = engine, pg_catalog;

--
-- TOC entry 3493 (class 0 OID 741732)
-- Dependencies: 186
-- Data for Name: attr_type; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY attr_type (attr_type_id, attr_type_descr) FROM stdin;
1	standard
2	fact
3	datetime
4	date
5	time
6	url
\.


--
-- TOC entry 3494 (class 0 OID 741735)
-- Dependencies: 187
-- Data for Name: attributes; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY attributes (attr_id, attr_name, attr_type_id, module_group_id, col_val_id, col_name_id, col_order_id, dataset_id) FROM stdin;
\.


--
-- TOC entry 3495 (class 0 OID 741741)
-- Dependencies: 188
-- Data for Name: col_datatype; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY col_datatype (col_datatype_id, col_datatype_descr, has_len) FROM stdin;
1	smallint	f
2	int	f
3	bigint	f
4	decimal	t
5	real	f
6	double precision	f
7	char	t
8	varchar	t
9	text	f
10	time	f
11	date	f
12	timestamp	f
13	jsonb	f
\.


--
-- TOC entry 3496 (class 0 OID 741744)
-- Dependencies: 189
-- Data for Name: col_type; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY col_type (col_type_id, col_type_descr, isdefault) FROM stdin;
1	pk	t
2	fk	t
3	fact	t
4	attr	t
6	ignore	t
8	pk_time	f
7	pk_date	f
5	datetime	t
\.


--
-- TOC entry 3497 (class 0 OID 741747)
-- Dependencies: 190
-- Data for Name: data_cols; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY data_cols (col_id, tbl_id, col_name, col_datatype_id, col_type_id, col_len, date_type_id) FROM stdin;
\.


--
-- TOC entry 3498 (class 0 OID 741750)
-- Dependencies: 191
-- Data for Name: data_tbls; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY data_tbls (tbl_id, tbl_name, last_upload, upload_status) FROM stdin;
\.


--
-- TOC entry 3499 (class 0 OID 741756)
-- Dependencies: 192
-- Data for Name: data_tbls_rel_cols; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY data_tbls_rel_cols (tbl_id, col_id, parent_tbl_id, parent_col_id) FROM stdin;
\.


--
-- TOC entry 3500 (class 0 OID 741759)
-- Dependencies: 193
-- Data for Name: dataset_type; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY dataset_type (dataset_type_id, dataset_type_descr, is_time_ds) FROM stdin;
1	fact	f
2	attr	f
3	snapshot	f
4	datetime	t
5	date	t
6	time	t
\.


--
-- TOC entry 3501 (class 0 OID 741762)
-- Dependencies: 194
-- Data for Name: datasets; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY datasets (dataset_id, dataset_name, dataset_type_id, created, modified, config_json, config_json_backup, last_upload, partitioned, is_created) FROM stdin;
\.


--
-- TOC entry 3502 (class 0 OID 741770)
-- Dependencies: 195
-- Data for Name: denied_attribute_usergroups; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY denied_attribute_usergroups (attr_id, usergroup_id) FROM stdin;
\.


--
-- TOC entry 3503 (class 0 OID 741773)
-- Dependencies: 196
-- Data for Name: denied_attribute_users; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY denied_attribute_users (attr_id, user_id) FROM stdin;
\.


--
-- TOC entry 3504 (class 0 OID 741776)
-- Dependencies: 197
-- Data for Name: denied_dataset_usergroups; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY denied_dataset_usergroups (dataset_id, usergroup_id) FROM stdin;
\.


--
-- TOC entry 3505 (class 0 OID 741779)
-- Dependencies: 198
-- Data for Name: denied_dataset_users; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY denied_dataset_users (dataset_id, user_id) FROM stdin;
\.


--
-- TOC entry 3506 (class 0 OID 741788)
-- Dependencies: 199
-- Data for Name: filter_type; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY filter_type (filter_type_id, filter_name, formula, attr_type_id) FROM stdin;
\.


--
-- TOC entry 3507 (class 0 OID 741797)
-- Dependencies: 200
-- Data for Name: measures_groups; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY measures_groups (measures_group_id, measures_group_name) FROM stdin;
b0c5a21b734b4daff84fa1609a0b3de0	Unsorted
67a0d6e7228e6ca1038cca1a68d83bb7	Sales
155b8267d66ea457100854f805973ec3	Rates
ecebbeb8664aa571cea08f8e60678d3c	Production Control
f44e48bf8c7dee0355bccef227124d7e	Orders
\.


--
-- TOC entry 3509 (class 0 OID 741802)
-- Dependencies: 202
-- Data for Name: object_types; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY object_types (object_type_id, object_type_name, object_type_descr, object_type_prefix) FROM stdin;
1	attributes	attr	\N
2	datasets	ds	\N
3	measures	m	\N
4	reports	rep	\N
5	dashboards	dash	\N
\.


--
-- TOC entry 3510 (class 0 OID 741806)
-- Dependencies: 203
-- Data for Name: time_date_definition; Type: TABLE DATA; Schema: engine; Owner: lotylda_admin
--

COPY time_date_definition (td_id, td_name, td_descr, td_data_type, td_type) FROM stdin;
1	date_pk	Date	int	1
2	year	Year	smallint	1
3	quarter	Quarter	smallint	1
4	month	Month	smallint	1
5	week	Week	smallint	1
6	day	Day	smallint	1
7	day_of_week	Day of Week	smallint	1
8	day_of_month	Day of Month	smallint	1
9	day_of_quarter	Day of Quarter	smallint	1
10	yearquarter	Year Quarter	int	1
11	yearmonth	Year Month	int	1
12	yearweek	Year Week	int	1
13	time_pk	Time Int	int	2
14	hour	Hour	smallint	2
15	minute	Minute	smallint	2
16	second	Second	smallint	2
\.


SET search_path = maintenance, pg_catalog;

--
-- TOC entry 3511 (class 0 OID 741812)
-- Dependencies: 204
-- Data for Name: data_integrity; Type: TABLE DATA; Schema: maintenance; Owner: lotylda_admin
--

COPY data_integrity (dati_id, created, result, descr) FROM stdin;
\.


--
-- TOC entry 3512 (class 0 OID 741818)
-- Dependencies: 205
-- Data for Name: data_upload; Type: TABLE DATA; Schema: maintenance; Owner: lotylda_admin
--

COPY data_upload (up_id, up_hash, up_start, up_end, up_result, up_log) FROM stdin;
1	33676dec60bf14484272e9d2c684180684a45a98	2016-02-22 13:05:17.309275	2016-02-22 13:05:17.579621	f	{}
2	7e44c3af23e481679398925ad6c53e9368f5a4d0	2016-02-22 13:10:10.519622	\N	\N	\N
3	680e3bc1b37974b89803a6f20fad87e33b7060bf	2016-02-22 13:19:52.838499	\N	\N	\N
4	94f024c6bb0e5a7aeceff665dda35c0a9a76fedf	2016-02-22 13:20:48.792712	\N	\N	\N
5	0d74dcc16d67e1b6b1830975647ccf3056b15b33	2016-02-22 13:27:24.308951	\N	\N	\N
6	627fb5860ae67eed86ef932734b5a69fd7f9a605	2016-02-22 13:31:17.935349	2016-02-22 13:31:30.085309	t	{}
7	7e80b108707b738a5c17c41b75764dc34fe7d9a9	2016-02-22 13:48:25.298111	2016-02-22 13:48:25.302927	f	{}
8	b499ac8e22fa99eb13d33711adc778e823b967e4	2016-02-22 13:49:58.171493	\N	\N	\N
9	18b9fa19f708688daf8e8e607e675568043ae7ab	2016-02-22 13:56:53.327099	\N	\N	\N
10	390c87e9327f67388b2d33c52c2baabd27501255	2016-02-22 14:01:25.902251	\N	\N	\N
11	789cc08008b62f05efa83c00a5602edb60927863	2016-02-22 14:10:51.458826	2016-02-22 14:10:56.522631	t	{}
12	91874f5009e45420a3e9df8dbfab3954ccb27ddf	2016-02-22 14:14:13.236367	2016-02-22 14:14:24.361151	t	{}
13	8d1d13bac8acc848e270f5ae337aeb3d461ab4fe	2016-02-22 14:40:21.998042	2016-02-22 14:40:36.139758	t	{"upload_end": "2016-02-22 14:40:46.734664", "upload_hash": "", "upload_start": "2016-02-22 14:40:20.335442", "upload_errors": "", "upload_status": "", "upload_datasets": [], "attr_refresh_end": "2016-02-22 14:40:46.734614", "attr_refresh_start": "2016-02-22 14:40:34.659804", "date_attr_refresh_end": "", "date_attr_refresh_start": ""}
14	3d8061e23a0f2dacbd96caff8d3d6242b0f5d9f4	2016-02-22 14:44:37.111172	2016-02-22 14:44:51.514567	t	{"upload_end": "2016-02-22 14:45:01.942804", "upload_hash": "", "upload_start": "2016-02-22 14:44:35.470007", "upload_errors": "", "upload_status": "", "upload_datasets": [], "attr_refresh_end": "2016-02-22 14:45:01.942749", "attr_refresh_start": "2016-02-22 14:44:50.025885", "date_attr_refresh_end": "", "date_attr_refresh_start": ""}
15	e4eea5110d6f3c897ff2fb6f7bb8999fab1f01b9	2016-02-22 14:48:52.782477	2016-02-22 14:49:06.721612	t	{"upload_end": "2016-02-22 14:49:19.589042", "upload_hash": "", "upload_start": "2016-02-22 14:48:51.131168", "upload_errors": "", "upload_status": "", "upload_datasets": [], "attr_refresh_end": "2016-02-22 14:49:19.588918", "attr_refresh_start": "2016-02-22 14:49:05.269374", "date_attr_refresh_end": "", "date_attr_refresh_start": ""}
16	6e3a3945bc8865e1a06b5e00a1a10a10985d1c92	2016-02-22 14:53:45.599739	\N	\N	\N
17	eeede7d1ce696ca389e7d96f88a1ec2589d538a3	2016-02-22 14:57:04.251785	2016-02-22 14:57:18.386229	t	{"upload_end": "2016-02-22 14:57:34.304840", "upload_hash": "", "upload_start": "2016-02-22 14:57:02.617946", "upload_errors": "", "upload_status": "", "upload_datasets": [], "attr_refresh_end": "2016-02-22 14:57:31.113297", "attr_refresh_start": "2016-02-22 14:57:16.953093", "date_attr_refresh_end": "", "date_attr_refresh_start": ""}
18	876185d6c467db8f6b09df939a111b5480337b27	2016-02-23 09:27:04.808339	2016-02-23 09:27:05.222544	t	{"upload_end": "2016-02-23 09:27:05.231202", "upload_hash": "876185d6c467db8f6b09df939a111b5480337b27", "upload_start": "2016-02-23 09:27:04.807990", "upload_errors": "", "upload_status": true, "upload_datasets": [{"dataset_id": "560e715d39edb0c63a1b322997cc3810", "upload_cfg": {}, "vacuum_end": "", "dataset_name": "", "vacuum_start": "", "data_load_end": "", "node_has_data": [], "upload_status": "Dataset does not exist.", "data_load_start": "", "attr_refresh_end": "", "data_load_errors": "", "attr_refresh_start": ""}], "date_attr_refresh_end": "", "date_attr_refresh_start": ""}
19	b88ffc3690983c2a11cea041c0c1501a2d9c5021	2016-02-23 09:30:02.782637	2016-02-23 09:30:03.181799	t	{"upload_end": "2016-02-23 09:30:03.184259", "upload_hash": "b88ffc3690983c2a11cea041c0c1501a2d9c5021", "upload_start": "2016-02-23 09:30:02.782273", "upload_errors": "", "upload_status": true, "upload_datasets": [{"dataset_id": "560e715d39edb0c63a1b322997cc3810", "upload_cfg": {}, "vacuum_end": "", "dataset_name": "", "vacuum_start": "", "data_load_end": "", "node_has_data": [], "upload_status": "Dataset does not exist.", "data_load_start": "", "attr_refresh_end": "", "data_load_errors": "", "attr_refresh_start": ""}], "date_attr_refresh_end": "", "date_attr_refresh_start": ""}
20	956208c12d4732d67857960830c0d729ab9cf2fa	2016-02-23 09:47:35.533629	2016-02-23 09:47:35.935931	t	{"upload_end": "2016-02-23 09:47:56.036590", "upload_hash": "956208c12d4732d67857960830c0d729ab9cf2fa", "upload_start": "2016-02-23 09:47:35.533370", "upload_errors": "", "upload_status": true, "upload_datasets": [{"dataset_id": "ds_758f56c751172211f605b6bfed02bd30", "upload_cfg": {"file": "weather.csv", "full": "false", "safe": "false", "header": "false", "dataset_id": "ds_758f56c751172211f605b6bfed02bd30"}, "vacuum_end": "2016-02-23 09:47:56.014270", "dataset_name": "Weather", "vacuum_start": "2016-02-23 09:47:52.932689", "data_load_end": "2016-02-23 09:47:50.128971", "node_has_data": [true, true, true, true, true, true, true, true], "upload_status": true, "data_load_start": "2016-02-23 09:47:35.939799", "attr_refresh_end": "2016-02-23 09:47:50.843453", "data_load_errors": "", "attr_refresh_start": "2016-02-23 09:47:50.130324"}], "date_attr_refresh_end": "", "date_attr_refresh_start": ""}
\.


--
-- TOC entry 3596 (class 0 OID 0)
-- Dependencies: 206
-- Name: data_upload_up_id_seq; Type: SEQUENCE SET; Schema: maintenance; Owner: lotylda_admin
--

SELECT pg_catalog.setval('data_upload_up_id_seq', 20, true);


SET search_path = public, pg_catalog;

--
-- TOC entry 3514 (class 0 OID 741827)
-- Dependencies: 207
-- Data for Name: auth_cas; Type: TABLE DATA; Schema: public; Owner: lotylda_admin
--

COPY auth_cas (id, user_id, created_on, service, ticket, renew) FROM stdin;
\.


--
-- TOC entry 3597 (class 0 OID 0)
-- Dependencies: 208
-- Name: auth_cas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('auth_cas_id_seq', 1, false);


--
-- TOC entry 3598 (class 0 OID 0)
-- Dependencies: 209
-- Name: auth_cas_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('auth_cas_id_seq1', 1, false);


--
-- TOC entry 3517 (class 0 OID 741837)
-- Dependencies: 210
-- Data for Name: auth_event; Type: TABLE DATA; Schema: public; Owner: lotylda_admin
--

COPY auth_event (id, time_stamp, client_ip, user_id, origin, description) FROM stdin;
\.


--
-- TOC entry 3599 (class 0 OID 0)
-- Dependencies: 211
-- Name: auth_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('auth_event_id_seq', 1, false);


--
-- TOC entry 3600 (class 0 OID 0)
-- Dependencies: 212
-- Name: auth_event_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('auth_event_id_seq1', 63, true);


--
-- TOC entry 3520 (class 0 OID 741847)
-- Dependencies: 213
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: lotylda_admin
--

COPY auth_group (id, role, description) FROM stdin;
\.


--
-- TOC entry 3601 (class 0 OID 0)
-- Dependencies: 214
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('auth_group_id_seq', 1, false);


--
-- TOC entry 3602 (class 0 OID 0)
-- Dependencies: 215
-- Name: auth_group_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('auth_group_id_seq1', 5, true);


--
-- TOC entry 3523 (class 0 OID 741857)
-- Dependencies: 216
-- Data for Name: auth_membership; Type: TABLE DATA; Schema: public; Owner: lotylda_admin
--

COPY auth_membership (id, user_id, group_id) FROM stdin;
\.


--
-- TOC entry 3603 (class 0 OID 0)
-- Dependencies: 217
-- Name: auth_membership_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('auth_membership_id_seq', 1, false);


--
-- TOC entry 3604 (class 0 OID 0)
-- Dependencies: 218
-- Name: auth_membership_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('auth_membership_id_seq1', 3, true);


--
-- TOC entry 3526 (class 0 OID 741873)
-- Dependencies: 219
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: lotylda_admin
--

COPY auth_permission (id, group_id, name, table_name, record_id) FROM stdin;
\.


--
-- TOC entry 3605 (class 0 OID 0)
-- Dependencies: 220
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('auth_permission_id_seq', 1, false);


--
-- TOC entry 3606 (class 0 OID 0)
-- Dependencies: 221
-- Name: auth_permission_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('auth_permission_id_seq1', 1, false);


--
-- TOC entry 3529 (class 0 OID 741883)
-- Dependencies: 222
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: lotylda_admin
--

COPY auth_user (id, first_name, last_name, email, username, password, registration_key, reset_password_key, registration_id, user_id, active) FROM stdin;
\.


--
-- TOC entry 3607 (class 0 OID 0)
-- Dependencies: 223
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('auth_user_id_seq', 1, false);


--
-- TOC entry 3608 (class 0 OID 0)
-- Dependencies: 224
-- Name: auth_user_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('auth_user_id_seq1', 6, true);


--
-- TOC entry 3609 (class 0 OID 0)
-- Dependencies: 201
-- Name: project_object_types_seq; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('project_object_types_seq', 5, true);


--
-- TOC entry 3532 (class 0 OID 741980)
-- Dependencies: 225
-- Data for Name: scheduler_run; Type: TABLE DATA; Schema: public; Owner: lotylda_admin
--

COPY scheduler_run (id, task_id, status, start_time, stop_time, run_output, run_result, traceback, worker_name) FROM stdin;
1	1	COMPLETED	2016-02-23 09:27:04	2016-02-23 09:27:05	Upload hash 876185d6c467db8f6b09df939a111b5480337b27 , 2016-02-23 09:27:04.807990 \n____________________________________________________________________________________________________\n\n\n/var/www/web2py/applications/fa0d30d321049b6efecb65abcde1b176/data_upload/876185d6c467db8f6b09df939a111b5480337b27\n[{u'header': u'false', u'dataset_id': u'560e715d39edb0c63a1b322997cc3810', u'full': u'false', u'safe': u'false', u'file': u'weather.csv'}]\n -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - \n\n\n	true	\N	lpar11-rhev7-81#24777
2	2	COMPLETED	2016-02-23 09:30:02	2016-02-23 09:30:03	Upload hash b88ffc3690983c2a11cea041c0c1501a2d9c5021 , 2016-02-23 09:30:02.782273 \n____________________________________________________________________________________________________\n\n\n/var/www/web2py/applications/fa0d30d321049b6efecb65abcde1b176/data_upload/b88ffc3690983c2a11cea041c0c1501a2d9c5021\n[{u'header': u'false', u'dataset_id': u'560e715d39edb0c63a1b322997cc3810', u'full': u'false', u'safe': u'false', u'file': u'weather.csv'}]\n -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - \n\n\n	true	\N	lpar11-rhev7-81#24777
3	3	COMPLETED	2016-02-23 09:47:35	2016-02-23 09:47:56	Upload hash 956208c12d4732d67857960830c0d729ab9cf2fa , 2016-02-23 09:47:35.533370 \n____________________________________________________________________________________________________\n\n\n/var/www/web2py/applications/fa0d30d321049b6efecb65abcde1b176/data_upload/956208c12d4732d67857960830c0d729ab9cf2fa\n[{u'header': u'false', u'dataset_id': u'ds_758f56c751172211f605b6bfed02bd30', u'full': u'false', u'safe': u'false', u'file': u'weather.csv'}]\n{'tbl_id': 'datastore.tbl_758f56c751172211f605b6bfed02bd30', 'config_json': {u'attr_group': u'Weather', u'part_column': u'12', u'relations': [], u'ds_name': u'Weather', u'tbl_name': u'weather_data', u'ds_type': u'fact', u'attributes': [{u'attr_name': u'Temperature', u'col_order': u'temperature_c', u'col_name': u'temperature_c', u'attr_type': u'fact', u'col_val': u'temperature_c'}, {u'attr_name': u'Dew point', u'col_order': u'dew_point_c', u'col_name': u'dew_point_c', u'attr_type': u'fact', u'col_val': u'dew_point_c'}, {u'attr_name': u'Humidity', u'col_order': u'humidity', u'col_name': u'humidity', u'attr_type': u'fact', u'col_val': u'humidity'}, {u'attr_name': u'Sea level pressure', u'col_order': u'sea_level_pressure_hpa', u'col_name': u'sea_level_pressure_hpa', u'attr_type': u'fact', u'col_val': u'sea_level_pressure_hpa'}, {u'attr_name': u'Visibility', u'col_order': u'visibility_km', u'col_name': u'visibility_km', u'attr_type': u'fact', u'col_val': u'visibility_km'}, {u'attr_name': u'Wind direction', u'col_order': u'wind_direction', u'col_name': u'wind_direction', u'attr_type': u'standard', u'col_val': u'wind_direction'}, {u'attr_name': u'Wind speed', u'col_order': u'wind_speed_kmh', u'col_name': u'wind_speed_kmh', u'attr_type': u'fact', u'col_val': u'wind_speed_kmh'}, {u'attr_name': u'Gust speed', u'col_order': u'gust_speed_kmh', u'col_name': u'gust_speed_kmh', u'attr_type': u'fact', u'col_val': u'gust_speed_kmh'}, {u'attr_name': u'Events', u'col_order': u'events', u'col_name': u'events', u'attr_type': u'standard', u'col_val': u'events'}, {u'attr_name': u'Conditions', u'col_order': u'conditions', u'col_name': u'conditions', u'attr_type': u'standard', u'col_val': u'conditions'}, {u'attr_name': u'Wind direction (degrees)', u'col_order': u'wind_dir_degrees', u'col_name': u'wind_dir_degrees', u'attr_type': u'fact', u'col_val': u'wind_dir_degrees'}, {u'attr_name': u'Date UTC', u'col_name': u'date_utc', u'attr_type': u'datetime', u'time_serie': u'date_utc'}, {u'attr_name': u'Local Time', u'col_name': u'time_local', u'attr_type': u'time', u'time_serie': u'local_time'}, {u'attr_name': u'Precipitation category', u'col_order': u'precipitation_cat', u'col_name': u'precipitation_cat', u'attr_type': u'standard', u'col_val': u'precipitation_cat'}, {u'attr_name': u'Temperature Interval', u'col_order': u'temp_int', u'col_name': u'temp_int', u'attr_type': u'standard', u'col_val': u'temp_int'}], u'columns': [{u'col_datatype': u'text', u'col_name': u'm_id', u'col_type': u'pk'}, {u'col_datatype': u'real', u'col_name': u'temperature_c', u'col_type': u'fact'}, {u'col_datatype': u'int', u'col_name': u'dew_point_c', u'col_type': u'fact'}, {u'col_datatype': u'int', u'col_name': u'humidity', u'col_type': u'fact'}, {u'col_datatype': u'int', u'col_name': u'sea_level_pressure_hpa', u'col_type': u'fact'}, {u'col_datatype': u'real', u'col_name': u'visibility_km', u'col_type': u'fact'}, {u'col_datatype': u'text', u'col_name': u'wind_direction', u'col_type': u'attr'}, {u'col_datatype': u'real', u'col_name': u'wind_speed_kmh', u'col_type': u'fact'}, {u'col_datatype': u'real', u'col_name': u'gust_speed_kmh', u'col_type': u'fact'}, {u'col_datatype': u'text', u'col_name': u'events', u'col_type': u'attr'}, {u'col_datatype': u'text', u'col_name': u'conditions', u'col_type': u'attr'}, {u'col_datatype': u'int', u'col_name': u'wind_dir_degrees', u'col_type': u'fact'}, {u'col_datatype': u'timestamp', u'col_name': u'date_utc', u'col_type': u'datetime'}, {u'col_datatype': u'text', u'col_name': u'station_code', u'col_type': u'fk'}, {u'col_datatype': u'time', u'col_name': u'time_local', u'col_type': u'datetime'}, {u'col_datatype': u'int', u'col_name': u'precipitation_cat', u'col_type': u'attr'}, {u'col_datatype': u'text', u'col_name': u'temp_int', u'col_type': u'attr'}]}, 'tbl_name': 'datastore.tbl_758f56c751172211f605b6bfed02bd30', 'partitioned': 12, 'dataset_name': 'Weather'}\n[{u'col_datatype': u'text', u'col_name': u'm_id', u'col_type': u'pk'}, {u'col_datatype': u'real', u'col_name': u'temperature_c', u'col_type': u'fact'}, {u'col_datatype': u'int', u'col_name': u'dew_point_c', u'col_type': u'fact'}, {u'col_datatype': u'int', u'col_name': u'humidity', u'col_type': u'fact'}, {u'col_datatype': u'int', u'col_name': u'sea_level_pressure_hpa', u'col_type': u'fact'}, {u'col_datatype': u'real', u'col_name': u'visibility_km', u'col_type': u'fact'}, {u'col_datatype': u'text', u'col_name': u'wind_direction', u'col_type': u'attr'}, {u'col_datatype': u'real', u'col_name': u'wind_speed_kmh', u'col_type': u'fact'}, {u'col_datatype': u'real', u'col_name': u'gust_speed_kmh', u'col_type': u'fact'}, {u'col_datatype': u'text', u'col_name': u'events', u'col_type': u'attr'}, {u'col_datatype': u'text', u'col_name': u'conditions', u'col_type': u'attr'}, {u'col_datatype': u'int', u'col_name': u'wind_dir_degrees', u'col_type': u'fact'}, {u'col_datatype': u'timestamp', u'col_name': u'date_utc', u'col_type': u'datetime'}, {u'col_datatype': u'text', u'col_name': u'station_code', u'col_type': u'fk'}, {u'col_datatype': u'time', u'col_name': u'time_local', u'col_type': u'datetime'}, {u'col_datatype': u'int', u'col_name': u'precipitation_cat', u'col_type': u'attr'}, {u'col_datatype': u'text', u'col_name': u'temp_int', u'col_type': u'attr'}]\n========================================================================================================================================================================================================\nLoading file:  weather.csv  into dataset(id):  ds_758f56c751172211f605b6bfed02bd30 | Is Full:  False , Is Safe:  , at 2016-02-23 09:47:35.939799\nfile_abs_path -->  /var/www/web2py/applications/fa0d30d321049b6efecb65abcde1b176/data_upload/956208c12d4732d67857960830c0d729ab9cf2fa/weather.csv\nfile_dir_path -->  /var/www/web2py/applications/fa0d30d321049b6efecb65abcde1b176/data_upload/956208c12d4732d67857960830c0d729ab9cf2fa\nawk res ==> 0\nFILE FOR NODE 0 EXISTS\nFILE FOR NODE 1 EXISTS\nFILE FOR NODE 2 EXISTS\nFILE FOR NODE 3 EXISTS\nFILE FOR NODE 4 EXISTS\nFILE FOR NODE 5 EXISTS\nFILE FOR NODE 6 EXISTS\nFILE FOR NODE 7 EXISTS\n -  -  -  -  -  -  -  -  -  - \n\nData load Finished at 2016-02-23 09:47:50.128851 \n\nupdate engine.data_tbls set last_upload = now()                         where tbl_id = 'datastore.tbl_758f56c751172211f605b6bfed02bd30'\nAttr refresh start 2016-02-23 09:47:50.130250 \n\nattr cache -->  attr_15889fd1814b7f881f75d8375571b2b3\nattr cache -->  attr_94f6c94f13520fc0aa1b12e054d12e6e\nattr cache -->  attr_b51a58b7ca1ee0bcec400e186525f8ae\nattr cache -->  attr_754a317e30315f87e65fd76b776c15b0\nattr cache -->  attr_655660734f3cab01a716fec52de8354d\n['INSERT INTO attrcache.attr_15889fd1814b7f881f75d8375571b2b3                                 SELECT DISTINCT col_15889fd1814b7f881f75d8375571b2b3, col_15889fd1814b7f881f75d8375571b2b3, col_15889fd1814b7f881f75d8375571b2b3 FROM datastore.tbl_758f56c751172211f605b6bfed02bd30_safe_load                                 EXCEPT SELECT col_val, col_name, col_order FROM attrcache.attr_15889fd1814b7f881f75d8375571b2b3', 'INSERT INTO attrcache.attr_94f6c94f13520fc0aa1b12e054d12e6e                                 SELECT DISTINCT col_94f6c94f13520fc0aa1b12e054d12e6e, col_94f6c94f13520fc0aa1b12e054d12e6e, col_94f6c94f13520fc0aa1b12e054d12e6e FROM datastore.tbl_758f56c751172211f605b6bfed02bd30_safe_load                                 EXCEPT SELECT col_val, col_name, col_order FROM attrcache.attr_94f6c94f13520fc0aa1b12e054d12e6e', 'INSERT INTO attrcache.attr_b51a58b7ca1ee0bcec400e186525f8ae                                 SELECT DISTINCT col_b51a58b7ca1ee0bcec400e186525f8ae, col_b51a58b7ca1ee0bcec400e186525f8ae, col_b51a58b7ca1ee0bcec400e186525f8ae FROM datastore.tbl_758f56c751172211f605b6bfed02bd30_safe_load                                 EXCEPT SELECT col_val, col_name, col_order FROM attrcache.attr_b51a58b7ca1ee0bcec400e186525f8ae', 'INSERT INTO attrcache.attr_754a317e30315f87e65fd76b776c15b0                                 SELECT DISTINCT col_754a317e30315f87e65fd76b776c15b0, col_754a317e30315f87e65fd76b776c15b0, col_754a317e30315f87e65fd76b776c15b0 FROM datastore.tbl_758f56c751172211f605b6bfed02bd30_safe_load                                 EXCEPT SELECT col_val, col_name, col_order FROM attrcache.attr_754a317e30315f87e65fd76b776c15b0', 'INSERT INTO attrcache.attr_655660734f3cab01a716fec52de8354d                                 SELECT DISTINCT col_655660734f3cab01a716fec52de8354d, col_655660734f3cab01a716fec52de8354d, col_655660734f3cab01a716fec52de8354d FROM datastore.tbl_758f56c751172211f605b6bfed02bd30_safe_load                                 EXCEPT SELECT col_val, col_name, col_order FROM attrcache.attr_655660734f3cab01a716fec52de8354d']\nAttr refresh end 2016-02-23 09:47:50.843559 \n\n -  -  -  -  -  -  -  -  -  - \nDROPUJI SAFE TABLES\nDROP TABLE IF EXISTS datastore.tbl_758f56c751172211f605b6bfed02bd30_safe_load;\nVacuum analyze on table datastore.tbl_758f56c751172211f605b6bfed02bd30 finished with success\n\nData Load Results :  [True, True, True, True, True, True, True, True]\n -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - \n\n\n	true	\N	lpar11-rhev7-81#24777
\.


--
-- TOC entry 3610 (class 0 OID 0)
-- Dependencies: 226
-- Name: scheduler_run_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('scheduler_run_id_seq', 1, false);


--
-- TOC entry 3611 (class 0 OID 0)
-- Dependencies: 227
-- Name: scheduler_run_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('scheduler_run_id_seq1', 3, true);


--
-- TOC entry 3535 (class 0 OID 741990)
-- Dependencies: 228
-- Data for Name: scheduler_task; Type: TABLE DATA; Schema: public; Owner: lotylda_admin
--

COPY scheduler_task (id, application_name, task_name, group_name, status, function_name, uuid, args, vars, enabled, start_time, next_run_time, stop_time, repeats, retry_failed, period, prevent_drift, timeout, sync_output, times_run, times_failed, last_run_time, assigned_worker_name) FROM stdin;
1	fa0d30d321049b6efecb65abcde1b176/data_upload	upload_data	main	COMPLETED	upload_data	1721ddff-bebc-4044-8af6-1bdd7d5383b2	["876185d6c467db8f6b09df939a111b5480337b27", "single", "hanzal@optisolutions.cz"]	{}	T	2016-02-23 09:26:42	2016-02-23 09:28:04	\N	1	0	60	F	4800	0	1	0	2016-02-23 09:27:04	lpar11-rhev7-81#24777
2	fa0d30d321049b6efecb65abcde1b176/data_upload	upload_data	main	COMPLETED	upload_data	e9718862-47ee-496b-98fa-6192644f4439	["b88ffc3690983c2a11cea041c0c1501a2d9c5021", "single", "hanzal@optisolutions.cz"]	{}	T	2016-02-23 09:29:54	2016-02-23 09:31:02	\N	1	0	60	F	4800	0	1	0	2016-02-23 09:30:02	lpar11-rhev7-81#24777
3	fa0d30d321049b6efecb65abcde1b176/data_upload	upload_data	main	COMPLETED	upload_data	6a7efaf1-5a02-46c0-99bd-faa3d9819221	["956208c12d4732d67857960830c0d729ab9cf2fa", "single", "hanzal@optisolutions.cz"]	{}	T	2016-02-23 09:47:26	2016-02-23 09:48:35	\N	1	0	60	F	4800	0	1	0	2016-02-23 09:47:35	lpar11-rhev7-81#24777
\.


--
-- TOC entry 3536 (class 0 OID 741996)
-- Dependencies: 229
-- Data for Name: scheduler_task_deps; Type: TABLE DATA; Schema: public; Owner: lotylda_admin
--

COPY scheduler_task_deps (id, job_name, task_parent, task_child, can_visit) FROM stdin;
\.


--
-- TOC entry 3612 (class 0 OID 0)
-- Dependencies: 230
-- Name: scheduler_task_deps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('scheduler_task_deps_id_seq', 1, false);


--
-- TOC entry 3613 (class 0 OID 0)
-- Dependencies: 231
-- Name: scheduler_task_deps_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('scheduler_task_deps_id_seq1', 1, false);


--
-- TOC entry 3614 (class 0 OID 0)
-- Dependencies: 232
-- Name: scheduler_task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('scheduler_task_id_seq', 1, false);


--
-- TOC entry 3615 (class 0 OID 0)
-- Dependencies: 233
-- Name: scheduler_task_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('scheduler_task_id_seq1', 3, true);


--
-- TOC entry 3541 (class 0 OID 742010)
-- Dependencies: 234
-- Data for Name: scheduler_worker; Type: TABLE DATA; Schema: public; Owner: lotylda_admin
--

COPY scheduler_worker (id, worker_name, first_heartbeat, last_heartbeat, status, is_ticker, group_names, worker_stats) FROM stdin;
1	lpar11-rhev7-81#24777	2016-02-23 09:26:43	2016-02-23 11:44:11	ACTIVE	T	|main|	{"status": "ACTIVE", "errors": 0, "workers": 1, "queue": 0, "empty_runs": 2321, "sleep": 3, "distribution": {"main": {"workers": [{"c": 0, "name": "lpar11-rhev7-81#24777"}]}}, "total": 3}
\.


--
-- TOC entry 3616 (class 0 OID 0)
-- Dependencies: 235
-- Name: scheduler_worker_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('scheduler_worker_id_seq', 1, false);


--
-- TOC entry 3617 (class 0 OID 0)
-- Dependencies: 236
-- Name: scheduler_worker_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: lotylda_admin
--

SELECT pg_catalog.setval('scheduler_worker_id_seq1', 1, true);


SET search_path = userspace, pg_catalog;

--
-- TOC entry 3544 (class 0 OID 742029)
-- Dependencies: 237
-- Data for Name: dashboard_filters; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY dashboard_filters (dashboard_filter_id, dashboard_id, filter_json, html_config) FROM stdin;
\.


--
-- TOC entry 3545 (class 0 OID 742035)
-- Dependencies: 238
-- Data for Name: dashboard_report_filters; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY dashboard_report_filters (report_id, dashboard_filter_id) FROM stdin;
\.


--
-- TOC entry 3546 (class 0 OID 742038)
-- Dependencies: 239
-- Data for Name: dashboard_reports; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY dashboard_reports (dashboard_id, report_id, coord_num, filter_json, repcache) FROM stdin;
\.


--
-- TOC entry 3547 (class 0 OID 742044)
-- Dependencies: 240
-- Data for Name: dashboard_user_groups; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY dashboard_user_groups (dashboard_id, usergroup_id, privilege_id) FROM stdin;
\.


--
-- TOC entry 3548 (class 0 OID 742047)
-- Dependencies: 241
-- Data for Name: dashboard_users; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY dashboard_users (user_id, privilege_id, dashboard_id) FROM stdin;
\.


--
-- TOC entry 3549 (class 0 OID 742056)
-- Dependencies: 242
-- Data for Name: dashboards; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY dashboards (dashboard_id, dashboard_name, dashboards_descr, created, created_user, modified, modified_user, config_json, status_id, module_group_id) FROM stdin;
\.


--
-- TOC entry 3550 (class 0 OID 742069)
-- Dependencies: 243
-- Data for Name: denied_object_usergroups; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY denied_object_usergroups (object_id, usergroup_id, object_type_id, privilege_id) FROM stdin;
\.


--
-- TOC entry 3551 (class 0 OID 742072)
-- Dependencies: 244
-- Data for Name: denied_object_users; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY denied_object_users (object_id, user_id, object_type_id, privilege_id) FROM stdin;
\.


--
-- TOC entry 3552 (class 0 OID 742075)
-- Dependencies: 245
-- Data for Name: measure_user_groups; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY measure_user_groups (measure_id, usergroup_id, privilege_id) FROM stdin;
\.


--
-- TOC entry 3553 (class 0 OID 742078)
-- Dependencies: 246
-- Data for Name: measure_users; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY measure_users (measure_id, user_id, privilege_id) FROM stdin;
\.


--
-- TOC entry 3554 (class 0 OID 742081)
-- Dependencies: 247
-- Data for Name: measures; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY measures (measure_id, measure_name, measure_descr, measure_tables, formula, format, created, created_user, modified, modified_user, module_group_id, formula_html, report_id, parent_measures) FROM stdin;
\.


--
-- TOC entry 3555 (class 0 OID 742091)
-- Dependencies: 248
-- Data for Name: module_groups; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY module_groups (module_group_id, module_group_name, module_group_descr, module_measures, module_reports, module_dashboards, module_attributes) FROM stdin;
b0c5a21b734b4daff84fa1609a0b3de0	Unsorted	Default group	t	t	t	t
\.


--
-- TOC entry 3556 (class 0 OID 742098)
-- Dependencies: 249
-- Data for Name: notes; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY notes (note_id, dashboard_id, user_id, config_json) FROM stdin;
\.


--
-- TOC entry 3557 (class 0 OID 742104)
-- Dependencies: 250
-- Data for Name: privileges; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY privileges (privilege_id, privilege_descr, privilege_name) FROM stdin;
-1	Driven by group	\N
1	Full Control	\N
2	Edit Content	\N
3	View Content	\N
4	No Access	\N
\.


--
-- TOC entry 3558 (class 0 OID 742107)
-- Dependencies: 251
-- Data for Name: repcache_report; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY repcache_report (repcache_id, report_id) FROM stdin;
\.


--
-- TOC entry 3559 (class 0 OID 742110)
-- Dependencies: 252
-- Data for Name: repcache_status; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY repcache_status (status_id, status_name) FROM stdin;
1	ready
2	running
3	error
\.


--
-- TOC entry 3560 (class 0 OID 742113)
-- Dependencies: 253
-- Data for Name: repcaches; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY repcaches (repcache_id, created, last_call, status_id, lolaq, valid_until, next_refresh, error_info) FROM stdin;
\.


--
-- TOC entry 3561 (class 0 OID 742120)
-- Dependencies: 254
-- Data for Name: report_comments; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY report_comments (report_id, report_comment_id, created, created_user, report_comment) FROM stdin;
\.


--
-- TOC entry 3618 (class 0 OID 0)
-- Dependencies: 255
-- Name: report_comments_report_comment_id_seq; Type: SEQUENCE SET; Schema: userspace; Owner: lotylda_admin
--

SELECT pg_catalog.setval('report_comments_report_comment_id_seq', 13, true);


--
-- TOC entry 3563 (class 0 OID 742129)
-- Dependencies: 256
-- Data for Name: report_notes; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY report_notes (report_note_id, report_id, user_id, config_json, dashboard_id) FROM stdin;
\.


--
-- TOC entry 3564 (class 0 OID 742135)
-- Dependencies: 257
-- Data for Name: report_user_groups; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY report_user_groups (report_id, usergroup_id, privilege_id, context_filter) FROM stdin;
\.


--
-- TOC entry 3565 (class 0 OID 742141)
-- Dependencies: 258
-- Data for Name: report_users; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY report_users (report_id, user_id, privilege_id, context_filter) FROM stdin;
\.


--
-- TOC entry 3566 (class 0 OID 742156)
-- Dependencies: 259
-- Data for Name: reports; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY reports (report_id, report_name, report_descr, created, created_user, modified, modified_user, config_json, option_json, module_group_id, status_id, repcache, cache_enabled, cache_json, edit_json) FROM stdin;
\.


--
-- TOC entry 3567 (class 0 OID 742167)
-- Dependencies: 260
-- Data for Name: status; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY status (status_id, status_descr) FROM stdin;
0	empty
1	draft
2	ready
3	edit
4	drill
\.


--
-- TOC entry 3568 (class 0 OID 742170)
-- Dependencies: 261
-- Data for Name: user_filter_cache; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY user_filter_cache (user_filter_cache_id, user_id, report_id, dashboard_id, cache_type_id, cache_json) FROM stdin;
\.


--
-- TOC entry 3569 (class 0 OID 742176)
-- Dependencies: 262
-- Data for Name: user_filter_cache_type; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY user_filter_cache_type (cache_type_id, cache_type_descr) FROM stdin;
1	context filter
2	dashboard filter
\.


--
-- TOC entry 3570 (class 0 OID 742179)
-- Dependencies: 263
-- Data for Name: user_tabs; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY user_tabs (user_tab_id, user_id, tab_name, report_id, dashboard_id, tab_index) FROM stdin;
\.


--
-- TOC entry 3571 (class 0 OID 742185)
-- Dependencies: 264
-- Data for Name: usergroup_users; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY usergroup_users (usergroup_id, user_id) FROM stdin;
\.


--
-- TOC entry 3572 (class 0 OID 742188)
-- Dependencies: 265
-- Data for Name: usergroups; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY usergroups (usergroup_id, usergroup_name, usergroup_descr, privilege_id, datafilter) FROM stdin;
\.


--
-- TOC entry 3573 (class 0 OID 742194)
-- Dependencies: 266
-- Data for Name: users; Type: TABLE DATA; Schema: userspace; Owner: lotylda_admin
--

COPY users (user_id, privilege_id, project_admin, username, datafilter) FROM stdin;
\.


SET search_path = engine, pg_catalog;

--
-- TOC entry 3181 (class 2606 OID 742455)
-- Name: idx_denied_attribute_users; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY denied_attribute_users
    ADD CONSTRAINT idx_denied_attribute_users PRIMARY KEY (attr_id, user_id);


--
-- TOC entry 3196 (class 2606 OID 742457)
-- Name: object_types_pkey; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY object_types
    ADD CONSTRAINT object_types_pkey PRIMARY KEY (object_type_id);


--
-- TOC entry 3150 (class 2606 OID 742459)
-- Name: pk_attr_type; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY attr_type
    ADD CONSTRAINT pk_attr_type PRIMARY KEY (attr_type_id);


--
-- TOC entry 3157 (class 2606 OID 742463)
-- Name: pk_col_datatype; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY col_datatype
    ADD CONSTRAINT pk_col_datatype PRIMARY KEY (col_datatype_id);


--
-- TOC entry 3159 (class 2606 OID 742465)
-- Name: pk_col_type; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY col_type
    ADD CONSTRAINT pk_col_type PRIMARY KEY (col_type_id);


--
-- TOC entry 3155 (class 2606 OID 742467)
-- Name: pk_data_attributes; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY attributes
    ADD CONSTRAINT pk_data_attributes PRIMARY KEY (attr_id);


--
-- TOC entry 3164 (class 2606 OID 742469)
-- Name: pk_data_cols; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY data_cols
    ADD CONSTRAINT pk_data_cols PRIMARY KEY (col_id);


--
-- TOC entry 3166 (class 2606 OID 742471)
-- Name: pk_data_tbls; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY data_tbls
    ADD CONSTRAINT pk_data_tbls PRIMARY KEY (tbl_id);


--
-- TOC entry 3172 (class 2606 OID 742473)
-- Name: pk_data_tbls_rel_cols; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY data_tbls_rel_cols
    ADD CONSTRAINT pk_data_tbls_rel_cols PRIMARY KEY (tbl_id, col_id, parent_tbl_id, parent_col_id);


--
-- TOC entry 3176 (class 2606 OID 742475)
-- Name: pk_datasets; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY datasets
    ADD CONSTRAINT pk_datasets PRIMARY KEY (dataset_id);


--
-- TOC entry 3179 (class 2606 OID 742477)
-- Name: pk_denied_attribute_usergroups; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY denied_attribute_usergroups
    ADD CONSTRAINT pk_denied_attribute_usergroups PRIMARY KEY (attr_id, usergroup_id);


--
-- TOC entry 3186 (class 2606 OID 742479)
-- Name: pk_denied_dataset_usergroups; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY denied_dataset_usergroups
    ADD CONSTRAINT pk_denied_dataset_usergroups PRIMARY KEY (dataset_id, usergroup_id);


--
-- TOC entry 3190 (class 2606 OID 742481)
-- Name: pk_denied_dataset_users; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY denied_dataset_users
    ADD CONSTRAINT pk_denied_dataset_users PRIMARY KEY (dataset_id, user_id);


--
-- TOC entry 3192 (class 2606 OID 742483)
-- Name: pk_filter_type; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY filter_type
    ADD CONSTRAINT pk_filter_type PRIMARY KEY (filter_type_id);


--
-- TOC entry 3194 (class 2606 OID 742485)
-- Name: pk_measures_group; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY measures_groups
    ADD CONSTRAINT pk_measures_group PRIMARY KEY (measures_group_id);


--
-- TOC entry 3174 (class 2606 OID 742487)
-- Name: pk_tbl_type; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY dataset_type
    ADD CONSTRAINT pk_tbl_type PRIMARY KEY (dataset_type_id);


--
-- TOC entry 3198 (class 2606 OID 742491)
-- Name: time_date_definition_pkey; Type: CONSTRAINT; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY time_date_definition
    ADD CONSTRAINT time_date_definition_pkey PRIMARY KEY (td_id);


SET search_path = maintenance, pg_catalog;

--
-- TOC entry 3200 (class 2606 OID 742493)
-- Name: data_integrity_pkey; Type: CONSTRAINT; Schema: maintenance; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY data_integrity
    ADD CONSTRAINT data_integrity_pkey PRIMARY KEY (dati_id);


--
-- TOC entry 3202 (class 2606 OID 742495)
-- Name: data_upload_pkey; Type: CONSTRAINT; Schema: maintenance; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY data_upload
    ADD CONSTRAINT data_upload_pkey PRIMARY KEY (up_id);


SET search_path = public, pg_catalog;

--
-- TOC entry 3204 (class 2606 OID 742497)
-- Name: auth_cas_pkey; Type: CONSTRAINT; Schema: public; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY auth_cas
    ADD CONSTRAINT auth_cas_pkey PRIMARY KEY (id);


--
-- TOC entry 3206 (class 2606 OID 742499)
-- Name: auth_event_pkey; Type: CONSTRAINT; Schema: public; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY auth_event
    ADD CONSTRAINT auth_event_pkey PRIMARY KEY (id);


--
-- TOC entry 3208 (class 2606 OID 742501)
-- Name: auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- TOC entry 3210 (class 2606 OID 742503)
-- Name: auth_membership_pkey; Type: CONSTRAINT; Schema: public; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY auth_membership
    ADD CONSTRAINT auth_membership_pkey PRIMARY KEY (id);


--
-- TOC entry 3212 (class 2606 OID 742505)
-- Name: auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 3214 (class 2606 OID 742507)
-- Name: auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- TOC entry 3216 (class 2606 OID 742511)
-- Name: pk_auth_user; Type: CONSTRAINT; Schema: public; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT pk_auth_user UNIQUE (user_id);


--
-- TOC entry 3218 (class 2606 OID 742557)
-- Name: scheduler_run_pkey; Type: CONSTRAINT; Schema: public; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY scheduler_run
    ADD CONSTRAINT scheduler_run_pkey PRIMARY KEY (id);


--
-- TOC entry 3224 (class 2606 OID 742559)
-- Name: scheduler_task_deps_pkey; Type: CONSTRAINT; Schema: public; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY scheduler_task_deps
    ADD CONSTRAINT scheduler_task_deps_pkey PRIMARY KEY (id);


--
-- TOC entry 3220 (class 2606 OID 742561)
-- Name: scheduler_task_pkey; Type: CONSTRAINT; Schema: public; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY scheduler_task
    ADD CONSTRAINT scheduler_task_pkey PRIMARY KEY (id);


--
-- TOC entry 3222 (class 2606 OID 742563)
-- Name: scheduler_task_uuid_key; Type: CONSTRAINT; Schema: public; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY scheduler_task
    ADD CONSTRAINT scheduler_task_uuid_key UNIQUE (uuid);


--
-- TOC entry 3226 (class 2606 OID 742565)
-- Name: scheduler_worker_pkey; Type: CONSTRAINT; Schema: public; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY scheduler_worker
    ADD CONSTRAINT scheduler_worker_pkey PRIMARY KEY (id);


--
-- TOC entry 3228 (class 2606 OID 742567)
-- Name: scheduler_worker_worker_name_key; Type: CONSTRAINT; Schema: public; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY scheduler_worker
    ADD CONSTRAINT scheduler_worker_worker_name_key UNIQUE (worker_name);


SET search_path = userspace, pg_catalog;

--
-- TOC entry 3246 (class 2606 OID 742571)
-- Name: idx_dashboard_users; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY dashboard_users
    ADD CONSTRAINT idx_dashboard_users PRIMARY KEY (dashboard_id, user_id);


--
-- TOC entry 3299 (class 2606 OID 742573)
-- Name: idx_report_users; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY report_users
    ADD CONSTRAINT idx_report_users PRIMARY KEY (report_id, user_id);


--
-- TOC entry 3231 (class 2606 OID 742575)
-- Name: pk_dashboard_filters; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY dashboard_filters
    ADD CONSTRAINT pk_dashboard_filters PRIMARY KEY (dashboard_filter_id);


--
-- TOC entry 3235 (class 2606 OID 742577)
-- Name: pk_dashboard_report_filters; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY dashboard_report_filters
    ADD CONSTRAINT pk_dashboard_report_filters PRIMARY KEY (report_id, dashboard_filter_id);


--
-- TOC entry 3239 (class 2606 OID 742579)
-- Name: pk_dashboard_reports; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY dashboard_reports
    ADD CONSTRAINT pk_dashboard_reports PRIMARY KEY (dashboard_id, report_id);


--
-- TOC entry 3244 (class 2606 OID 742581)
-- Name: pk_dashboard_user_groups; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY dashboard_user_groups
    ADD CONSTRAINT pk_dashboard_user_groups PRIMARY KEY (dashboard_id, usergroup_id);


--
-- TOC entry 3252 (class 2606 OID 742583)
-- Name: pk_dashboards; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY dashboards
    ADD CONSTRAINT pk_dashboards PRIMARY KEY (dashboard_id);


--
-- TOC entry 3254 (class 2606 OID 742585)
-- Name: pk_denied_object_usergroups; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY denied_object_usergroups
    ADD CONSTRAINT pk_denied_object_usergroups PRIMARY KEY (object_id, usergroup_id);


--
-- TOC entry 3256 (class 2606 OID 742587)
-- Name: pk_denied_object_uses; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY denied_object_users
    ADD CONSTRAINT pk_denied_object_uses PRIMARY KEY (object_id, user_id);


--
-- TOC entry 3261 (class 2606 OID 742589)
-- Name: pk_measure_user_groups; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY measure_user_groups
    ADD CONSTRAINT pk_measure_user_groups PRIMARY KEY (measure_id, usergroup_id);


--
-- TOC entry 3268 (class 2606 OID 742591)
-- Name: pk_measures; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY measures
    ADD CONSTRAINT pk_measures PRIMARY KEY (measure_id);


--
-- TOC entry 3265 (class 2606 OID 742593)
-- Name: pk_measures_users; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY measure_users
    ADD CONSTRAINT pk_measures_users PRIMARY KEY (measure_id, user_id);


--
-- TOC entry 3271 (class 2606 OID 742595)
-- Name: pk_module_groups; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY module_groups
    ADD CONSTRAINT pk_module_groups PRIMARY KEY (module_group_id);


--
-- TOC entry 3275 (class 2606 OID 742597)
-- Name: pk_notes; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT pk_notes PRIMARY KEY (note_id);


--
-- TOC entry 3277 (class 2606 OID 742599)
-- Name: pk_privileges; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY privileges
    ADD CONSTRAINT pk_privileges PRIMARY KEY (privilege_id);


--
-- TOC entry 3292 (class 2606 OID 742601)
-- Name: pk_report_notes; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY report_notes
    ADD CONSTRAINT pk_report_notes PRIMARY KEY (report_note_id);


--
-- TOC entry 3297 (class 2606 OID 742603)
-- Name: pk_report_user_groups; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY report_user_groups
    ADD CONSTRAINT pk_report_user_groups PRIMARY KEY (report_id, usergroup_id);


--
-- TOC entry 3304 (class 2606 OID 742605)
-- Name: pk_reports; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT pk_reports PRIMARY KEY (report_id);


--
-- TOC entry 3306 (class 2606 OID 742607)
-- Name: pk_status; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY status
    ADD CONSTRAINT pk_status PRIMARY KEY (status_id);


--
-- TOC entry 3315 (class 2606 OID 742609)
-- Name: pk_user_tabs; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY user_tabs
    ADD CONSTRAINT pk_user_tabs PRIMARY KEY (user_tab_id);


--
-- TOC entry 3319 (class 2606 OID 742611)
-- Name: pk_usergroup_users; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY usergroup_users
    ADD CONSTRAINT pk_usergroup_users PRIMARY KEY (usergroup_id, user_id);


--
-- TOC entry 3321 (class 2606 OID 742613)
-- Name: pk_usergroups; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY usergroups
    ADD CONSTRAINT pk_usergroups PRIMARY KEY (usergroup_id);


--
-- TOC entry 3324 (class 2606 OID 742615)
-- Name: pk_users; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT pk_users PRIMARY KEY (user_id);


--
-- TOC entry 3279 (class 2606 OID 742617)
-- Name: repcache_report_pkey; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY repcache_report
    ADD CONSTRAINT repcache_report_pkey PRIMARY KEY (repcache_id, report_id);


--
-- TOC entry 3281 (class 2606 OID 742619)
-- Name: repcache_status_pkey; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY repcache_status
    ADD CONSTRAINT repcache_status_pkey PRIMARY KEY (status_id);


--
-- TOC entry 3283 (class 2606 OID 742621)
-- Name: repcaches_pkey; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY repcaches
    ADD CONSTRAINT repcaches_pkey PRIMARY KEY (repcache_id);


--
-- TOC entry 3286 (class 2606 OID 742623)
-- Name: report_comments_pkey; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY report_comments
    ADD CONSTRAINT report_comments_pkey PRIMARY KEY (report_id, report_comment_id);


--
-- TOC entry 3308 (class 2606 OID 742625)
-- Name: user_filter_cache_pkey; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY user_filter_cache
    ADD CONSTRAINT user_filter_cache_pkey PRIMARY KEY (user_filter_cache_id);


--
-- TOC entry 3310 (class 2606 OID 742627)
-- Name: user_filter_cache_type_pkey; Type: CONSTRAINT; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

ALTER TABLE ONLY user_filter_cache_type
    ADD CONSTRAINT user_filter_cache_type_pkey PRIMARY KEY (cache_type_id);


SET search_path = engine, pg_catalog;

--
-- TOC entry 3151 (class 1259 OID 742632)
-- Name: idx_data_attributes; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_data_attributes ON attributes USING btree (attr_type_id);


--
-- TOC entry 3152 (class 1259 OID 742633)
-- Name: idx_data_attributes_0; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_data_attributes_0 ON attributes USING btree (col_val_id);


--
-- TOC entry 3153 (class 1259 OID 742634)
-- Name: idx_data_attributes_1; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_data_attributes_1 ON attributes USING btree (dataset_id);


--
-- TOC entry 3160 (class 1259 OID 742635)
-- Name: idx_data_cols; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_data_cols ON data_cols USING btree (tbl_id);


--
-- TOC entry 3161 (class 1259 OID 742636)
-- Name: idx_data_cols_0; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_data_cols_0 ON data_cols USING btree (col_type_id);


--
-- TOC entry 3162 (class 1259 OID 742637)
-- Name: idx_data_cols_2; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_data_cols_2 ON data_cols USING btree (col_datatype_id);


--
-- TOC entry 3167 (class 1259 OID 742638)
-- Name: idx_data_tbls_rel_cols; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_data_tbls_rel_cols ON data_tbls_rel_cols USING btree (tbl_id);


--
-- TOC entry 3168 (class 1259 OID 742639)
-- Name: idx_data_tbls_rel_cols_0; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_data_tbls_rel_cols_0 ON data_tbls_rel_cols USING btree (parent_tbl_id);


--
-- TOC entry 3169 (class 1259 OID 742640)
-- Name: idx_data_tbls_rel_cols_1; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_data_tbls_rel_cols_1 ON data_tbls_rel_cols USING btree (col_id);


--
-- TOC entry 3170 (class 1259 OID 742641)
-- Name: idx_data_tbls_rel_cols_2; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_data_tbls_rel_cols_2 ON data_tbls_rel_cols USING btree (parent_col_id);


--
-- TOC entry 3177 (class 1259 OID 742642)
-- Name: idx_denied_attribute_usergroups_0; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_denied_attribute_usergroups_0 ON denied_attribute_usergroups USING btree (usergroup_id);


--
-- TOC entry 3182 (class 1259 OID 742643)
-- Name: idx_denied_attribute_users_0; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_denied_attribute_users_0 ON denied_attribute_users USING btree (user_id);


--
-- TOC entry 3183 (class 1259 OID 742644)
-- Name: idx_denied_dataset_usergroups; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_denied_dataset_usergroups ON denied_dataset_usergroups USING btree (dataset_id);


--
-- TOC entry 3184 (class 1259 OID 742645)
-- Name: idx_denied_dataset_usergroups_users; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_denied_dataset_usergroups_users ON denied_dataset_usergroups USING btree (usergroup_id);


--
-- TOC entry 3187 (class 1259 OID 742646)
-- Name: idx_denied_dataset_users; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_denied_dataset_users ON denied_dataset_users USING btree (dataset_id);


--
-- TOC entry 3188 (class 1259 OID 742647)
-- Name: idx_denied_dataset_users_users; Type: INDEX; Schema: engine; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_denied_dataset_users_users ON denied_dataset_users USING btree (user_id);


SET search_path = userspace, pg_catalog;

--
-- TOC entry 3229 (class 1259 OID 742648)
-- Name: idx_dashboard_filters; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_dashboard_filters ON dashboard_filters USING btree (dashboard_id);


--
-- TOC entry 3232 (class 1259 OID 742649)
-- Name: idx_dashboard_report_filters; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_dashboard_report_filters ON dashboard_report_filters USING btree (report_id);


--
-- TOC entry 3233 (class 1259 OID 742650)
-- Name: idx_dashboard_report_filters_0; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_dashboard_report_filters_0 ON dashboard_report_filters USING btree (dashboard_filter_id);


--
-- TOC entry 3236 (class 1259 OID 742651)
-- Name: idx_dashboard_reports; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_dashboard_reports ON dashboard_reports USING btree (dashboard_id);


--
-- TOC entry 3237 (class 1259 OID 742652)
-- Name: idx_dashboard_reports_0; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_dashboard_reports_0 ON dashboard_reports USING btree (report_id);


--
-- TOC entry 3240 (class 1259 OID 742653)
-- Name: idx_dashboard_user_groups; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_dashboard_user_groups ON dashboard_user_groups USING btree (usergroup_id);


--
-- TOC entry 3241 (class 1259 OID 742654)
-- Name: idx_dashboard_user_groups_0; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_dashboard_user_groups_0 ON dashboard_user_groups USING btree (privilege_id);


--
-- TOC entry 3247 (class 1259 OID 742661)
-- Name: idx_dashboard_users_0; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_dashboard_users_0 ON dashboard_users USING btree (dashboard_id);


--
-- TOC entry 3248 (class 1259 OID 742665)
-- Name: idx_dashboard_users_1; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_dashboard_users_1 ON dashboard_users USING btree (user_id);


--
-- TOC entry 3242 (class 1259 OID 742666)
-- Name: idx_dashboard_users_2; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_dashboard_users_2 ON dashboard_user_groups USING btree (dashboard_id);


--
-- TOC entry 3249 (class 1259 OID 742667)
-- Name: idx_dashboard_users_5; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_dashboard_users_5 ON dashboard_users USING btree (privilege_id);


--
-- TOC entry 3250 (class 1259 OID 742668)
-- Name: idx_dashboards; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_dashboards ON dashboards USING btree (status_id);


--
-- TOC entry 3257 (class 1259 OID 742669)
-- Name: idx_measure_user_groups; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_measure_user_groups ON measure_user_groups USING btree (measure_id);


--
-- TOC entry 3258 (class 1259 OID 742670)
-- Name: idx_measure_user_groups_0; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_measure_user_groups_0 ON measure_user_groups USING btree (usergroup_id);


--
-- TOC entry 3259 (class 1259 OID 742671)
-- Name: idx_measure_user_groups_1; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_measure_user_groups_1 ON measure_user_groups USING btree (privilege_id);


--
-- TOC entry 3266 (class 1259 OID 742672)
-- Name: idx_measures; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_measures ON measures USING btree (module_group_id);


--
-- TOC entry 3262 (class 1259 OID 742673)
-- Name: idx_measures_users; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_measures_users ON measure_users USING btree (measure_id);


--
-- TOC entry 3263 (class 1259 OID 742674)
-- Name: idx_measures_users_0; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_measures_users_0 ON measure_users USING btree (user_id);


--
-- TOC entry 3272 (class 1259 OID 742675)
-- Name: idx_notes; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_notes ON notes USING btree (user_id);


--
-- TOC entry 3273 (class 1259 OID 742676)
-- Name: idx_notes_dashboard_id; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_notes_dashboard_id ON notes USING btree (dashboard_id);


--
-- TOC entry 3284 (class 1259 OID 742677)
-- Name: idx_report_comments; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_report_comments ON report_comments USING btree (created);


--
-- TOC entry 3288 (class 1259 OID 742678)
-- Name: idx_report_notes; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_report_notes ON report_notes USING btree (report_id);


--
-- TOC entry 3289 (class 1259 OID 742679)
-- Name: idx_report_notes_0; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_report_notes_0 ON report_notes USING btree (user_id);


--
-- TOC entry 3290 (class 1259 OID 742680)
-- Name: idx_report_notes_1; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_report_notes_1 ON report_notes USING btree (dashboard_id);


--
-- TOC entry 3293 (class 1259 OID 742681)
-- Name: idx_report_user_groups; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_report_user_groups ON report_user_groups USING btree (report_id);


--
-- TOC entry 3294 (class 1259 OID 742682)
-- Name: idx_report_user_groups_0; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_report_user_groups_0 ON report_user_groups USING btree (usergroup_id);


--
-- TOC entry 3295 (class 1259 OID 742683)
-- Name: idx_report_user_groups_1; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_report_user_groups_1 ON report_user_groups USING btree (privilege_id);


--
-- TOC entry 3300 (class 1259 OID 742684)
-- Name: idx_report_users_0; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_report_users_0 ON report_users USING btree (user_id);


--
-- TOC entry 3301 (class 1259 OID 742685)
-- Name: idx_reports; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_reports ON reports USING btree (module_group_id);


--
-- TOC entry 3302 (class 1259 OID 742686)
-- Name: idx_reports_0; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_reports_0 ON reports USING btree (status_id);


--
-- TOC entry 3311 (class 1259 OID 742687)
-- Name: idx_user_tabs; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_user_tabs ON user_tabs USING btree (user_id);


--
-- TOC entry 3312 (class 1259 OID 742688)
-- Name: idx_user_tabs_0; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_user_tabs_0 ON user_tabs USING btree (dashboard_id);


--
-- TOC entry 3313 (class 1259 OID 742689)
-- Name: idx_user_tabs_1; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_user_tabs_1 ON user_tabs USING btree (report_id);


--
-- TOC entry 3316 (class 1259 OID 742690)
-- Name: idx_usergroup_users; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_usergroup_users ON usergroup_users USING btree (usergroup_id);


--
-- TOC entry 3317 (class 1259 OID 742691)
-- Name: idx_usergroup_users_0; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_usergroup_users_0 ON usergroup_users USING btree (user_id);


--
-- TOC entry 3322 (class 1259 OID 742692)
-- Name: idx_users; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX idx_users ON users USING btree (privilege_id);


--
-- TOC entry 3269 (class 1259 OID 742693)
-- Name: module_groups_module_reports; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX module_groups_module_reports ON module_groups USING btree (module_reports);


--
-- TOC entry 3287 (class 1259 OID 742694)
-- Name: report_comments_report_id; Type: INDEX; Schema: userspace; Owner: lotylda_admin; Tablespace: 
--

CREATE INDEX report_comments_report_id ON report_comments USING btree (report_id);


SET search_path = public, pg_catalog;

--
-- TOC entry 3383 (class 2620 OID 742695)
-- Name: update_users; Type: TRIGGER; Schema: public; Owner: lotylda_admin
--

CREATE TRIGGER update_users AFTER INSERT ON auth_user FOR EACH STATEMENT EXECUTE PROCEDURE update_users();


SET search_path = engine, pg_catalog;

--
-- TOC entry 3325 (class 2606 OID 742696)
-- Name: attributes_module_group_id_fkey; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY attributes
    ADD CONSTRAINT attributes_module_group_id_fkey FOREIGN KEY (module_group_id) REFERENCES userspace.module_groups(module_group_id);


--
-- TOC entry 3326 (class 2606 OID 742701)
-- Name: fk_data_attributes; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY attributes
    ADD CONSTRAINT fk_data_attributes FOREIGN KEY (attr_type_id) REFERENCES attr_type(attr_type_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3327 (class 2606 OID 742706)
-- Name: fk_data_attributes_col_val; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY attributes
    ADD CONSTRAINT fk_data_attributes_col_val FOREIGN KEY (col_val_id) REFERENCES data_cols(col_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3328 (class 2606 OID 742711)
-- Name: fk_data_attributes_dataset; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY attributes
    ADD CONSTRAINT fk_data_attributes_dataset FOREIGN KEY (dataset_id) REFERENCES datasets(dataset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3329 (class 2606 OID 742716)
-- Name: fk_data_cols; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY data_cols
    ADD CONSTRAINT fk_data_cols FOREIGN KEY (tbl_id) REFERENCES data_tbls(tbl_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3330 (class 2606 OID 742721)
-- Name: fk_data_cols_col_datatype; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY data_cols
    ADD CONSTRAINT fk_data_cols_col_datatype FOREIGN KEY (col_datatype_id) REFERENCES col_datatype(col_datatype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3331 (class 2606 OID 742726)
-- Name: fk_data_cols_type; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY data_cols
    ADD CONSTRAINT fk_data_cols_type FOREIGN KEY (col_type_id) REFERENCES col_type(col_type_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3332 (class 2606 OID 742731)
-- Name: fk_data_tbls_rel_cols_cols; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY data_tbls_rel_cols
    ADD CONSTRAINT fk_data_tbls_rel_cols_cols FOREIGN KEY (col_id) REFERENCES data_cols(col_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3333 (class 2606 OID 742736)
-- Name: fk_data_tbls_rel_cols_cols_parent; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY data_tbls_rel_cols
    ADD CONSTRAINT fk_data_tbls_rel_cols_cols_parent FOREIGN KEY (parent_col_id) REFERENCES data_cols(col_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3334 (class 2606 OID 742741)
-- Name: fk_data_tbls_rel_cols_tbls; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY data_tbls_rel_cols
    ADD CONSTRAINT fk_data_tbls_rel_cols_tbls FOREIGN KEY (tbl_id) REFERENCES data_tbls(tbl_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3335 (class 2606 OID 742746)
-- Name: fk_data_tbls_rel_cols_tbls_parent; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY data_tbls_rel_cols
    ADD CONSTRAINT fk_data_tbls_rel_cols_tbls_parent FOREIGN KEY (parent_tbl_id) REFERENCES data_tbls(tbl_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3336 (class 2606 OID 742751)
-- Name: fk_datasets_type; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY datasets
    ADD CONSTRAINT fk_datasets_type FOREIGN KEY (dataset_type_id) REFERENCES dataset_type(dataset_type_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3337 (class 2606 OID 742756)
-- Name: fk_denied_attribute_usergroups_usergroups; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY denied_attribute_usergroups
    ADD CONSTRAINT fk_denied_attribute_usergroups_usergroups FOREIGN KEY (usergroup_id) REFERENCES userspace.usergroups(usergroup_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3338 (class 2606 OID 742761)
-- Name: fk_denied_attribute_users_users; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY denied_attribute_users
    ADD CONSTRAINT fk_denied_attribute_users_users FOREIGN KEY (user_id) REFERENCES userspace.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3339 (class 2606 OID 742766)
-- Name: fk_denied_dataset_usergroups; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY denied_dataset_usergroups
    ADD CONSTRAINT fk_denied_dataset_usergroups FOREIGN KEY (dataset_id) REFERENCES datasets(dataset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3340 (class 2606 OID 742771)
-- Name: fk_denied_dataset_usergroups_users; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY denied_dataset_usergroups
    ADD CONSTRAINT fk_denied_dataset_usergroups_users FOREIGN KEY (usergroup_id) REFERENCES userspace.usergroups(usergroup_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3341 (class 2606 OID 742776)
-- Name: fk_denied_dataset_users; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY denied_dataset_users
    ADD CONSTRAINT fk_denied_dataset_users FOREIGN KEY (dataset_id) REFERENCES datasets(dataset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3342 (class 2606 OID 742781)
-- Name: fk_filter_type; Type: FK CONSTRAINT; Schema: engine; Owner: lotylda_admin
--

ALTER TABLE ONLY filter_type
    ADD CONSTRAINT fk_filter_type FOREIGN KEY (attr_type_id) REFERENCES attr_type(attr_type_id) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = public, pg_catalog;

--
-- TOC entry 3343 (class 2606 OID 742786)
-- Name: auth_cas_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY auth_cas
    ADD CONSTRAINT auth_cas_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE;


--
-- TOC entry 3344 (class 2606 OID 742791)
-- Name: auth_event_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY auth_event
    ADD CONSTRAINT auth_event_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE;


--
-- TOC entry 3345 (class 2606 OID 742796)
-- Name: auth_membership_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY auth_membership
    ADD CONSTRAINT auth_membership_group_id_fkey FOREIGN KEY (group_id) REFERENCES auth_group(id) ON DELETE CASCADE;


--
-- TOC entry 3346 (class 2606 OID 742801)
-- Name: auth_membership_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY auth_membership
    ADD CONSTRAINT auth_membership_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE;


--
-- TOC entry 3347 (class 2606 OID 742806)
-- Name: auth_permission_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_group_id_fkey FOREIGN KEY (group_id) REFERENCES auth_group(id) ON DELETE CASCADE;


--
-- TOC entry 3348 (class 2606 OID 742811)
-- Name: scheduler_run_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY scheduler_run
    ADD CONSTRAINT scheduler_run_task_id_fkey FOREIGN KEY (task_id) REFERENCES scheduler_task(id) ON DELETE CASCADE;


--
-- TOC entry 3349 (class 2606 OID 742816)
-- Name: scheduler_task_deps_task_child_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lotylda_admin
--

ALTER TABLE ONLY scheduler_task_deps
    ADD CONSTRAINT scheduler_task_deps_task_child_fkey FOREIGN KEY (task_child) REFERENCES scheduler_task(id) ON DELETE CASCADE;


SET search_path = userspace, pg_catalog;

--
-- TOC entry 3355 (class 2606 OID 742821)
-- Name: dashboards_module_group_id_fkey; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY dashboards
    ADD CONSTRAINT dashboards_module_group_id_fkey FOREIGN KEY (module_group_id) REFERENCES module_groups(module_group_id);


--
-- TOC entry 3360 (class 2606 OID 742826)
-- Name: denied_object_usergroups_object_type_id_fkey; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY denied_object_users
    ADD CONSTRAINT denied_object_usergroups_object_type_id_fkey FOREIGN KEY (object_type_id) REFERENCES engine.object_types(object_type_id);


--
-- TOC entry 3357 (class 2606 OID 742831)
-- Name: denied_object_usergroups_object_type_id_fkey; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY denied_object_usergroups
    ADD CONSTRAINT denied_object_usergroups_object_type_id_fkey FOREIGN KEY (object_type_id) REFERENCES engine.object_types(object_type_id);


--
-- TOC entry 3358 (class 2606 OID 742836)
-- Name: denied_object_usergroups_privilege_id_fkey; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY denied_object_usergroups
    ADD CONSTRAINT denied_object_usergroups_privilege_id_fkey FOREIGN KEY (privilege_id) REFERENCES privileges(privilege_id);


--
-- TOC entry 3359 (class 2606 OID 742841)
-- Name: denied_object_usergroups_usergroup_id_fkey; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY denied_object_usergroups
    ADD CONSTRAINT denied_object_usergroups_usergroup_id_fkey FOREIGN KEY (usergroup_id) REFERENCES usergroups(usergroup_id);


--
-- TOC entry 3361 (class 2606 OID 742846)
-- Name: denied_object_users_privilege_id_fkey; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY denied_object_users
    ADD CONSTRAINT denied_object_users_privilege_id_fkey FOREIGN KEY (privilege_id) REFERENCES privileges(privilege_id);


--
-- TOC entry 3362 (class 2606 OID 742851)
-- Name: denied_object_users_user_id_fkey; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY denied_object_users
    ADD CONSTRAINT denied_object_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id);


--
-- TOC entry 3350 (class 2606 OID 742856)
-- Name: fk_dashboard_report_filters; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY dashboard_report_filters
    ADD CONSTRAINT fk_dashboard_report_filters FOREIGN KEY (dashboard_filter_id) REFERENCES dashboard_filters(dashboard_filter_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3351 (class 2606 OID 742861)
-- Name: fk_dashboard_user_groups_authgroup; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY dashboard_user_groups
    ADD CONSTRAINT fk_dashboard_user_groups_authgroup FOREIGN KEY (usergroup_id) REFERENCES usergroups(usergroup_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3352 (class 2606 OID 742866)
-- Name: fk_dashboard_user_groups_privileges; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY dashboard_user_groups
    ADD CONSTRAINT fk_dashboard_user_groups_privileges FOREIGN KEY (privilege_id) REFERENCES privileges(privilege_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3353 (class 2606 OID 742871)
-- Name: fk_dashboard_users_auth_user; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY dashboard_users
    ADD CONSTRAINT fk_dashboard_users_auth_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3354 (class 2606 OID 742876)
-- Name: fk_dashboard_users_privileges; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY dashboard_users
    ADD CONSTRAINT fk_dashboard_users_privileges FOREIGN KEY (privilege_id) REFERENCES privileges(privilege_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3356 (class 2606 OID 742881)
-- Name: fk_dashboards_status; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY dashboards
    ADD CONSTRAINT fk_dashboards_status FOREIGN KEY (status_id) REFERENCES status(status_id);


--
-- TOC entry 3363 (class 2606 OID 742886)
-- Name: fk_measure_user_groups_authgroup; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY measure_user_groups
    ADD CONSTRAINT fk_measure_user_groups_authgroup FOREIGN KEY (usergroup_id) REFERENCES usergroups(usergroup_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3364 (class 2606 OID 742891)
-- Name: fk_measure_user_groups_privileges; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY measure_user_groups
    ADD CONSTRAINT fk_measure_user_groups_privileges FOREIGN KEY (privilege_id) REFERENCES privileges(privilege_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3366 (class 2606 OID 742896)
-- Name: fk_measures_module_groups; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY measures
    ADD CONSTRAINT fk_measures_module_groups FOREIGN KEY (module_group_id) REFERENCES module_groups(module_group_id);


--
-- TOC entry 3365 (class 2606 OID 742901)
-- Name: fk_measures_users_auth_user; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY measure_users
    ADD CONSTRAINT fk_measures_users_auth_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3367 (class 2606 OID 742906)
-- Name: fk_notes_auth_user; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT fk_notes_auth_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3371 (class 2606 OID 742911)
-- Name: fk_report_notes_auth_user; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY report_notes
    ADD CONSTRAINT fk_report_notes_auth_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3372 (class 2606 OID 742916)
-- Name: fk_report_user_groups_auth_group; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY report_user_groups
    ADD CONSTRAINT fk_report_user_groups_auth_group FOREIGN KEY (usergroup_id) REFERENCES usergroups(usergroup_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3373 (class 2606 OID 742921)
-- Name: fk_report_user_groups_privileges; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY report_user_groups
    ADD CONSTRAINT fk_report_user_groups_privileges FOREIGN KEY (privilege_id) REFERENCES privileges(privilege_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3374 (class 2606 OID 742926)
-- Name: fk_report_users_auth_user; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY report_users
    ADD CONSTRAINT fk_report_users_auth_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3375 (class 2606 OID 742931)
-- Name: fk_report_users_privileges; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY report_users
    ADD CONSTRAINT fk_report_users_privileges FOREIGN KEY (privilege_id) REFERENCES privileges(privilege_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3376 (class 2606 OID 742936)
-- Name: fk_reports_module_groups; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT fk_reports_module_groups FOREIGN KEY (module_group_id) REFERENCES module_groups(module_group_id);


--
-- TOC entry 3377 (class 2606 OID 742941)
-- Name: fk_reports_status; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT fk_reports_status FOREIGN KEY (status_id) REFERENCES status(status_id);


--
-- TOC entry 3379 (class 2606 OID 742946)
-- Name: fk_user_tabs_auth_user; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY user_tabs
    ADD CONSTRAINT fk_user_tabs_auth_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3380 (class 2606 OID 742951)
-- Name: fk_usergroup_users_usergroups; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY usergroup_users
    ADD CONSTRAINT fk_usergroup_users_usergroups FOREIGN KEY (usergroup_id) REFERENCES usergroups(usergroup_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3381 (class 2606 OID 742956)
-- Name: fk_usergroup_users_users; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY usergroup_users
    ADD CONSTRAINT fk_usergroup_users_users FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3382 (class 2606 OID 742961)
-- Name: fk_users_privileges; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_users_privileges FOREIGN KEY (privilege_id) REFERENCES privileges(privilege_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3368 (class 2606 OID 742972)
-- Name: repcache_report_repcache_id_fkey; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY repcache_report
    ADD CONSTRAINT repcache_report_repcache_id_fkey FOREIGN KEY (repcache_id) REFERENCES repcaches(repcache_id);


--
-- TOC entry 3369 (class 2606 OID 742980)
-- Name: repcache_report_report_id_fkey; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY repcache_report
    ADD CONSTRAINT repcache_report_report_id_fkey FOREIGN KEY (report_id) REFERENCES reports(report_id);


--
-- TOC entry 3370 (class 2606 OID 742985)
-- Name: repcaches_status_id_fkey; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY repcaches
    ADD CONSTRAINT repcaches_status_id_fkey FOREIGN KEY (status_id) REFERENCES repcache_status(status_id);


--
-- TOC entry 3378 (class 2606 OID 742990)
-- Name: user_filter_cache_cache_type_id_fkey; Type: FK CONSTRAINT; Schema: userspace; Owner: lotylda_admin
--

ALTER TABLE ONLY user_filter_cache
    ADD CONSTRAINT user_filter_cache_cache_type_id_fkey FOREIGN KEY (cache_type_id) REFERENCES user_filter_cache_type(cache_type_id);


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 12
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-02-29 15:52:42 CET

--
-- PostgreSQL database dump complete
--

