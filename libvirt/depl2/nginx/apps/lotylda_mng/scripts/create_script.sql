CREATE SCHEMA engine;

CREATE SCHEMA engine_config;

CREATE SCHEMA maintenance;

CREATE SCHEMA "public";

CREATE SCHEMA repcache;

CREATE SCHEMA attrcache;

CREATE SCHEMA "temp";

CREATE SCHEMA userspace;

CREATE SEQUENCE "public".auth_cas_id_seq START WITH 1;

CREATE SEQUENCE "public".auth_event_id_seq START WITH 1;

CREATE SEQUENCE "public".auth_group_id_seq START WITH 1;

CREATE SEQUENCE "public".auth_membership_id_seq START WITH 1;

CREATE SEQUENCE "public".auth_permission_id_seq START WITH 1;

CREATE SEQUENCE "public".auth_user_id_seq START WITH 1;

CREATE SEQUENCE "public".scheduler_run_id_seq START WITH 1;

CREATE SEQUENCE "public".scheduler_task_deps_id_seq START WITH 1;

CREATE SEQUENCE "public".scheduler_task_id_seq START WITH 1;

CREATE SEQUENCE "public".scheduler_worker_id_seq START WITH 1;

CREATE TABLE engine.attr_type ( 
	attr_type_id         smallint  NOT NULL,
	attr_type_descr      varchar(50)  ,
	CONSTRAINT pk_attr_type PRIMARY KEY ( attr_type_id )
 );

CREATE TABLE engine.attributes_groups ( 
	attr_group_id        varchar(50)  NOT NULL,
	attr_group_name      varchar(100)  NOT NULL,
	CONSTRAINT pk_attributes_groups PRIMARY KEY ( attr_group_id )
 );

CREATE TABLE engine.col_datatype ( 
	col_datatype_id      smallint  NOT NULL,
	col_datatype_descr   varchar(50)  ,
	CONSTRAINT pk_col_datatype PRIMARY KEY ( col_datatype_id )
 );

CREATE TABLE engine.col_type ( 
	col_type_id          smallint  NOT NULL,
	col_type_descr       varchar(50)  ,
	CONSTRAINT pk_col_type PRIMARY KEY ( col_type_id )
 );

CREATE TABLE engine.data_tbls ( 
	tbl_id               varchar(50)  NOT NULL,
	tbl_name             varchar(100)  ,
	last_upload          timestamp  ,
	upload_status        json  ,
	CONSTRAINT pk_data_tbls PRIMARY KEY ( tbl_id )
 );

CREATE TABLE engine.dataset_type ( 
	dataset_type_id      smallint  NOT NULL,
	dataset_type_descr   varchar(50)  ,
	CONSTRAINT pk_tbl_type PRIMARY KEY ( dataset_type_id )
 );

CREATE TABLE engine.datasets ( 
	dataset_id           varchar(50)  NOT NULL,
	dataset_name         varchar(100)  NOT NULL,
	dataset_type_id      smallint  NOT NULL,
	created              timestamp  ,
	modified             timestamp  ,
	config_json          json  ,
	config_json_backup   json  ,
	last_upload          timestamp  ,
	partitioned          smallint DEFAULT (-1) ,
	CONSTRAINT pk_datasets PRIMARY KEY ( dataset_id )
 );

CREATE TABLE engine.denied_dataset_usergroups ( 
	dataset_id           varchar(50)  NOT NULL,
	usergroup_id         varchar(50)  NOT NULL,
	CONSTRAINT pk_denied_dataset_usergroups PRIMARY KEY ( dataset_id, usergroup_id )
 );

CREATE INDEX idx_denied_dataset_usergroups ON engine.denied_dataset_usergroups ( dataset_id );

CREATE INDEX idx_denied_dataset_usergroups_users ON engine.denied_dataset_usergroups ( usergroup_id );

CREATE TABLE engine.denied_dataset_users ( 
	dataset_id           varchar(50)  NOT NULL,
	user_id              varchar(50)  NOT NULL,
	CONSTRAINT pk_denied_dataset_users PRIMARY KEY ( dataset_id, user_id )
 );

CREATE INDEX idx_denied_dataset_users ON engine.denied_dataset_users ( dataset_id );

CREATE INDEX idx_denied_dataset_users_users ON engine.denied_dataset_users ( user_id );

CREATE TABLE engine.filter_type ( 
	filter_type_id       smallint  NOT NULL,
	filter_name          text  NOT NULL,
	formula              text  NOT NULL,
	attr_type_id         smallint  ,
	CONSTRAINT pk_filter_type PRIMARY KEY ( filter_type_id )
 );

CREATE TABLE engine.measures_groups ( 
	measures_group_id    varchar(50)  NOT NULL,
	measures_group_name  varchar(100)  ,
	CONSTRAINT pk_measures_group PRIMARY KEY ( measures_group_id )
 );

CREATE TABLE engine.timedimension_definitions ( 
	"variable"           varchar(50)  NOT NULL,
	formula              varchar(100)  NOT NULL,
	descr                varchar(50)  ,
	CONSTRAINT pk_timedimensions PRIMARY KEY ( "variable" )
 );

CREATE TABLE engine.data_cols ( 
	col_id               varchar(50)  NOT NULL,
	tbl_id               varchar(50)  ,
	col_name             varchar(100)  ,
	col_datatype_id      smallint  ,
	col_type_id          smallint  ,
	CONSTRAINT pk_data_cols PRIMARY KEY ( col_id )
 );

CREATE INDEX idx_data_cols ON engine.data_cols ( tbl_id );

CREATE INDEX idx_data_cols_2 ON engine.data_cols ( col_datatype_id );

CREATE INDEX idx_data_cols_0 ON engine.data_cols ( col_type_id );

CREATE TABLE engine.data_tbls_rel_cols ( 
	tbl_id               varchar(50)  NOT NULL,
	col_id               varchar(50)  NOT NULL,
	parent_tbl_id        varchar(50)  NOT NULL,
	parent_col_id        varchar(50)  NOT NULL,
	CONSTRAINT pk_data_tbls_rel_cols PRIMARY KEY ( tbl_id, col_id, parent_tbl_id, parent_col_id )
 );

CREATE INDEX idx_data_tbls_rel_cols ON engine.data_tbls_rel_cols ( tbl_id );

CREATE INDEX idx_data_tbls_rel_cols_0 ON engine.data_tbls_rel_cols ( parent_tbl_id );

CREATE INDEX idx_data_tbls_rel_cols_1 ON engine.data_tbls_rel_cols ( col_id );

CREATE INDEX idx_data_tbls_rel_cols_2 ON engine.data_tbls_rel_cols ( parent_col_id );

CREATE TABLE engine.measures ( 
	measure_id           varchar(50)  NOT NULL,
	measure_name         varchar(100)  ,
	formula              varchar(255)  ,
	tbl_id               varchar(50)  ,
	format               varchar(255)  ,
	measures_group_id    varchar(50) DEFAULT md5('default-unsorted'::text) ,
	measures_descr       text  ,
	created              timestamp DEFAULT now() ,
	modified             timestamp DEFAULT now() ,
	created_user         varchar(50)  ,
	modified_user        varchar(50)  ,
	CONSTRAINT pk_measures PRIMARY KEY ( measure_id )
 );

CREATE INDEX pk_measures_0 ON engine.measures ( tbl_id );

CREATE INDEX idx_measures ON engine.measures ( measures_group_id );

CREATE TABLE engine.attributes ( 
	attr_id              varchar(50)  NOT NULL,
	attr_name            varchar(100)  NOT NULL,
	attr_type_id         smallint  NOT NULL,
	col_val_id           varchar(50)  NOT NULL,
	col_name_id          varchar(50)  ,
	col_order_id         varchar(50)  ,
	dataset_level        smallint DEFAULT 0 ,
	dataset_id           varchar(50)  NOT NULL,
	attribute_level      smallint DEFAULT (-1) ,
	CONSTRAINT pk_data_attributes PRIMARY KEY ( attr_id )
 );

CREATE INDEX idx_data_attributes ON engine.attributes ( attr_type_id );

CREATE INDEX idx_data_attributes_0 ON engine.attributes ( col_val_id );

CREATE INDEX idx_data_attributes_1 ON engine.attributes ( dataset_id );

CREATE TABLE engine.denied_attribute_usergroups ( 
	attr_id              varchar(50)  NOT NULL,
	usergroup_id         varchar(50)  NOT NULL,
	CONSTRAINT pk_denied_attribute_usergroups PRIMARY KEY ( attr_id, usergroup_id )
 );

CREATE INDEX idx_denied_attribute_usergroups_0 ON engine.denied_attribute_usergroups ( usergroup_id );

CREATE TABLE engine.denied_attribute_users ( 
	attr_id              varchar(50)  NOT NULL,
	user_id              varchar(50)  NOT NULL,
	CONSTRAINT idx_denied_attribute_users PRIMARY KEY ( attr_id, user_id )
 );

CREATE INDEX idx_denied_attribute_users_0 ON engine.denied_attribute_users ( user_id );

CREATE TABLE engine_config.data_tbls ( 
	tbl_id               varchar(50)  NOT NULL,
	tbl_name             varchar(100)  ,
	last_upload          timestamp  ,
	CONSTRAINT pk_data_tbls PRIMARY KEY ( tbl_id )
 );

CREATE TABLE engine_config.data_tbls_rel_cols ( 
	tbl_id               varchar(50)  NOT NULL,
	col_id               varchar(50)  NOT NULL,
	parent_tbl_id        varchar(50)  NOT NULL,
	parent_col_id        varchar(50)  NOT NULL,
	CONSTRAINT pk_data_tbls_rel_cols PRIMARY KEY ( tbl_id, col_id, parent_tbl_id, parent_col_id )
 );

CREATE TABLE engine_config.files ( 
	file_id              varchar(50)  NOT NULL,
	file_name            varchar(64)  ,
	file_data            bytea  ,
	created              timestamp  ,
	CONSTRAINT files_pkey PRIMARY KEY ( file_id )
 );

CREATE TABLE engine_config.data_cols ( 
	col_id               varchar(50)  NOT NULL,
	tbl_id               varchar(50)  ,
	col_name             varchar(100)  ,
	col_datatype_id      smallint  ,
	col_type_id          smallint  ,
	CONSTRAINT pk_data_cols PRIMARY KEY ( col_id )
 );

CREATE TABLE engine_config.datasets ( 
	dataset_id           varchar(50)  NOT NULL,
	dataset_name         varchar(100)  NOT NULL,
	dataset_type_id      smallint  NOT NULL,
	created              timestamp  ,
	modified             timestamp  ,
	config_json          json  ,
	config_json_backup   json  ,
	partitioned          smallint DEFAULT (-1) ,
	file_id              varchar(50)  ,
	CONSTRAINT pk_datasets PRIMARY KEY ( dataset_id )
 );

CREATE TABLE engine_config.attributes ( 
	attr_id              varchar(50)  NOT NULL,
	attr_name            varchar(100)  NOT NULL,
	attr_type_id         smallint  NOT NULL,
	col_val_id           varchar(50)  NOT NULL,
	col_name_id          varchar(50)  ,
	col_order_id         varchar(50)  ,
	dataset_level        smallint DEFAULT 0 ,
	dataset_id           varchar(50)  NOT NULL,
	attribute_level      smallint DEFAULT (-1) ,
	CONSTRAINT pk_data_attributes PRIMARY KEY ( attr_id )
 );
 
CREATE TABLE maintenance.data_integrity (
  dati_id integer NOT NULL,
  created timestamp without time zone,
  result boolean,
  descr json,
  CONSTRAINT data_integrity_pkey PRIMARY KEY (dati_id)
 );
 
CREATE TABLE maintenance.error_source (
  source_id integer NOT NULL,
  source_name character varying(32),
  CONSTRAINT error_source_pkey PRIMARY KEY (source_id)
);

CREATE TABLE maintenance.error_log
(
  err_id bigserial NOT NULL,
  created timestamp without time zone,
  source_id integer,
  description json,
  CONSTRAINT error_log_pkey PRIMARY KEY (err_id),
  CONSTRAINT error_log_source_id_fkey FOREIGN KEY (source_id)
      REFERENCES maintenance.error_source (source_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE "public".auth_group ( 
	id                   serial  NOT NULL,
	"role"               varchar(512)  ,
	description          text  ,
	usergroup_id         varchar(50)  ,
	CONSTRAINT auth_group_pkey PRIMARY KEY ( id ),
	CONSTRAINT pk_auth_group UNIQUE ( usergroup_id ) 
 );

CREATE TABLE "public".auth_permission ( 
	id                   serial  NOT NULL,
	group_id             integer  ,
	name                 varchar(512)  ,
	"table_name"         varchar(512)  ,
	record_id            integer  ,
	CONSTRAINT auth_permission_pkey PRIMARY KEY ( id )
 );

CREATE TABLE "public".auth_user ( 
	id                   serial  NOT NULL,
	first_name           varchar(128)  ,
	last_name            varchar(128)  ,
	email                varchar(512)  ,
	"password"           varchar(512)  ,
	registration_key     varchar(512)  ,
	reset_password_key   varchar(512)  ,
	registration_id      varchar(512)  ,
	user_id              varchar(50)  ,
	active               bool DEFAULT false ,
	username             varchar(128)  ,
	CONSTRAINT auth_user_pkey PRIMARY KEY ( id ),
	CONSTRAINT pk_auth_user UNIQUE ( user_id ) 
 );

CREATE TABLE "public".scheduler_task ( 
	id                   serial  NOT NULL,
	application_name     varchar(512)  ,
	task_name            varchar(512)  ,
	group_name           varchar(512)  ,
	status               varchar(512)  ,
	function_name        varchar(512)  ,
	uuid                 varchar(255)  ,
	args                 text  ,
	vars                 text  ,
	enabled              char(1)  ,
	start_time           timestamp  ,
	next_run_time        timestamp  ,
	stop_time            timestamp  ,
	repeats              integer  ,
	retry_failed         integer  ,
	period               integer  ,
	prevent_drift        char(1)  ,
	timeout              integer  ,
	sync_output          integer  ,
	times_run            integer  ,
	times_failed         integer  ,
	last_run_time        timestamp  ,
	assigned_worker_name varchar(512)  ,
	CONSTRAINT scheduler_task_pkey PRIMARY KEY ( id ),
	CONSTRAINT scheduler_task_uuid_key UNIQUE ( uuid ) 
 );

CREATE TABLE "public".scheduler_task_deps ( 
	id                   serial  NOT NULL,
	job_name             varchar(512)  ,
	task_parent          integer  ,
	task_child           integer  ,
	can_visit            char(1)  ,
	CONSTRAINT scheduler_task_deps_pkey PRIMARY KEY ( id )
 );

CREATE TABLE "public".scheduler_worker ( 
	id                   serial  NOT NULL,
	worker_name          varchar(255)  ,
	first_heartbeat      timestamp  ,
	last_heartbeat       timestamp  ,
	status               varchar(512)  ,
	is_ticker            char(1)  ,
	group_names          text  ,
	worker_stats         json  ,
	CONSTRAINT scheduler_worker_pkey PRIMARY KEY ( id ),
	CONSTRAINT scheduler_worker_worker_name_key UNIQUE ( worker_name ) 
 );

CREATE TABLE "public".auth_cas ( 
	id                   serial  NOT NULL,
	user_id              integer  ,
	created_on           timestamp  ,
	service              varchar(512)  ,
	ticket               varchar(512)  ,
	renew                char(1)  ,
	CONSTRAINT auth_cas_pkey PRIMARY KEY ( id )
 );

CREATE TABLE "public".auth_event ( 
	id                   serial  NOT NULL,
	time_stamp           timestamp  ,
	client_ip            varchar(512)  ,
	user_id              integer  ,
	origin               varchar(512)  ,
	description          text  ,
	CONSTRAINT auth_event_pkey PRIMARY KEY ( id )
 );

CREATE TABLE "public".auth_membership ( 
	id                   serial  NOT NULL,
	user_id              integer  ,
	group_id             integer  ,
	CONSTRAINT auth_membership_pkey PRIMARY KEY ( id )
 );

CREATE TABLE "public".scheduler_run ( 
	id                   serial  NOT NULL,
	task_id              integer  ,
	status               varchar(512)  ,
	start_time           timestamp  ,
	stop_time            timestamp  ,
	run_output           text  ,
	run_result           text  ,
	traceback            text  ,
	worker_name          varchar(512)  ,
	CONSTRAINT scheduler_run_pkey PRIMARY KEY ( id )
 );

CREATE TABLE userspace.dashboards_groups ( 
	dashboards_group_id  varchar(50)  NOT NULL,
	dashboards_group_name varchar(100)  ,
	CONSTRAINT pk_dashboards_groups PRIMARY KEY ( dashboards_group_id )
 );

CREATE TABLE userspace."privileges" ( 
	privilege_id         smallint  NOT NULL,
	privilege_descr      varchar(64)  ,
	privilege_name       varchar(50)  ,
	CONSTRAINT pk_privileges PRIMARY KEY ( privilege_id )
 );

CREATE TABLE userspace.reports_groups ( 
	reports_group_id     varchar(50)  NOT NULL,
	reports_group_name   varchar(100)  ,
	CONSTRAINT pk_reports_groups PRIMARY KEY ( reports_group_id )
 );

CREATE TABLE userspace.status ( 
	status_id            smallint  NOT NULL,
	status_descr         varchar(50)  NOT NULL,
	CONSTRAINT pk_status PRIMARY KEY ( status_id )
 );

CREATE TABLE userspace.user_filter_cache_type ( 
	cache_type_id        integer  NOT NULL,
	cache_type_descr     varchar(50)  ,
	CONSTRAINT user_filter_cache_type_pkey PRIMARY KEY ( cache_type_id )
 );

CREATE TABLE userspace.usergroups ( 
	usergroup_id         varchar(50)  NOT NULL,
	usergroup_name       varchar(100)  ,
	usergroup_descr      varchar(255)  ,
	privilege_id         smallint  ,
	datafilter           json  ,
	CONSTRAINT pk_usergroups PRIMARY KEY ( usergroup_id )
 );

CREATE TABLE userspace.users ( 
	user_id              varchar(50)  NOT NULL,
	privilege_id         smallint DEFAULT -1 NOT NULL,
	project_admin        bool DEFAULT false NOT NULL,
	username             varchar(128)  ,
	datafilter           json  ,
	CONSTRAINT pk_users PRIMARY KEY ( user_id )
 );

CREATE INDEX idx_users ON userspace.users ( privilege_id );

CREATE TABLE userspace.dashboards ( 
	dashboard_id         varchar(50)  NOT NULL,
	dashboard_name       varchar(100)  NOT NULL,
	created              timestamp DEFAULT current_timestamp ,
	created_user         varchar(50)  ,
	modified             timestamp DEFAULT current_timestamp ,
	modified_user        varchar(50)  ,
	config_json          json  ,
	status_id            smallint DEFAULT 1 ,
	dashboards_descr     text  ,
	dashboards_group_id  varchar(50) DEFAULT md5('default-unsorted'::text) ,
	CONSTRAINT pk_dashboards PRIMARY KEY ( dashboard_id )
 );

CREATE INDEX idx_dashboards ON userspace.dashboards ( status_id );

CREATE TABLE userspace.measure_user_groups ( 
	measure_id           varchar(50)  NOT NULL,
	usergroup_id         varchar(50)  NOT NULL,
	privilege_id         smallint  ,
	CONSTRAINT pk_measure_user_groups PRIMARY KEY ( measure_id, usergroup_id )
 );

CREATE INDEX idx_measure_user_groups ON userspace.measure_user_groups ( measure_id );

CREATE INDEX idx_measure_user_groups_0 ON userspace.measure_user_groups ( usergroup_id );

CREATE INDEX idx_measure_user_groups_1 ON userspace.measure_user_groups ( privilege_id );

CREATE TABLE userspace.measure_users ( 
	measure_id           varchar(50)  NOT NULL,
	user_id              varchar(50)  NOT NULL,
	privilege_id         smallint  ,
	CONSTRAINT pk_measures_users PRIMARY KEY ( measure_id, user_id )
 );

CREATE INDEX idx_measures_users ON userspace.measure_users ( measure_id );

CREATE INDEX idx_measures_users_0 ON userspace.measure_users ( user_id );

CREATE TABLE userspace.notes ( 
	note_id              varchar(50)  NOT NULL,
	dashboard_id         varchar(50)  ,
	user_id              varchar(50)  ,
	config_json          json  ,
	CONSTRAINT pk_notes PRIMARY KEY ( note_id )
 );

CREATE INDEX idx_notes_dashboard_id ON userspace.notes ( dashboard_id );

CREATE INDEX idx_notes ON userspace.notes ( user_id );

CREATE TABLE userspace.reports ( 
	report_id            varchar(50)  NOT NULL,
	report_name          varchar(100)  NOT NULL,
	created              timestamp DEFAULT current_timestamp ,
	created_user         varchar(50)  ,
	modified             timestamp DEFAULT current_timestamp ,
	modified_user        varchar(50)  ,
	config_json          json  ,
	option_json          json  ,
	reports_group_id     varchar(50) DEFAULT md5('default-unsorted'::text) ,
	status_id            smallint DEFAULT 1 ,
	repcache             json  ,
	cache_enabled        bool DEFAULT true ,
	cache_json           json  ,
	reports_descr        text  ,
	edit_json            json  ,
	CONSTRAINT pk_reports PRIMARY KEY ( report_id )
 );

CREATE INDEX idx_reports ON userspace.reports ( reports_group_id );

CREATE INDEX idx_reports_0 ON userspace.reports ( status_id );

CREATE TABLE userspace.user_filter_cache ( 
	user_filter_cache_id varchar(50)  NOT NULL,
	user_id              varchar(50)  ,
	report_id            varchar(50)  ,
	dashboard_id         varchar(50)  ,
	cache_type_id        integer  ,
	cache_json           json  ,
	CONSTRAINT user_filter_cache_pkey PRIMARY KEY ( user_filter_cache_id )
 );

CREATE TABLE userspace.user_tabs ( 
	user_tab_id          varchar(50)  NOT NULL,
	user_id              varchar(50)  ,
	tab_name             varchar(100)  ,
	report_id            varchar(50) DEFAULT 'empty' ,
	dashboard_id         varchar(50) DEFAULT 'empty' ,
	tab_index            smallint DEFAULT 0 ,
	CONSTRAINT pk_user_tabs PRIMARY KEY ( user_tab_id )
 );

CREATE INDEX idx_user_tabs ON userspace.user_tabs ( user_id );

CREATE INDEX idx_user_tabs_0 ON userspace.user_tabs ( dashboard_id );

CREATE INDEX idx_user_tabs_1 ON userspace.user_tabs ( report_id );

CREATE TABLE userspace.usergroup_users ( 
	usergroup_id         varchar(50)  NOT NULL,
	user_id              varchar(50)  NOT NULL,
	CONSTRAINT pk_usergroup_users PRIMARY KEY ( usergroup_id, user_id )
 );

CREATE INDEX idx_usergroup_users ON userspace.usergroup_users ( usergroup_id );

CREATE INDEX idx_usergroup_users_0 ON userspace.usergroup_users ( user_id );

CREATE TABLE userspace.dashboard_filters ( 
	dashboard_filter_id  varchar(50)  NOT NULL,
	dashboard_id         varchar(50)  ,
	filter_json          json  ,
	html_config          json  ,
	CONSTRAINT pk_dashboard_filters PRIMARY KEY ( dashboard_filter_id )
 );

CREATE INDEX idx_dashboard_filters ON userspace.dashboard_filters ( dashboard_id );

CREATE TABLE userspace.dashboard_report_filters ( 
	report_id            varchar(50)  NOT NULL,
	dashboard_filter_id  varchar(50)  NOT NULL,
	CONSTRAINT pk_dashboard_report_filters PRIMARY KEY ( report_id, dashboard_filter_id )
 );

CREATE INDEX idx_dashboard_report_filters ON userspace.dashboard_report_filters ( report_id );

CREATE INDEX idx_dashboard_report_filters_0 ON userspace.dashboard_report_filters ( dashboard_filter_id );

CREATE TABLE userspace.dashboard_reports ( 
	dashboard_id         varchar(50)  NOT NULL,
	report_id            varchar(50)  NOT NULL,
	coord_num            integer  NOT NULL,
	filter_json          json  ,
	repcache             json  ,
	CONSTRAINT pk_dashboard_reports PRIMARY KEY ( dashboard_id, report_id )
 );

CREATE INDEX idx_dashboard_reports ON userspace.dashboard_reports ( dashboard_id );

CREATE INDEX idx_dashboard_reports_0 ON userspace.dashboard_reports ( report_id );

CREATE TABLE userspace.dashboard_user_groups ( 
	dashboard_id         varchar(50)  NOT NULL,
	usergroup_id         varchar(50)  NOT NULL,
	privilege_id         smallint  ,
	CONSTRAINT pk_dashboard_user_groups PRIMARY KEY ( dashboard_id, usergroup_id )
 );

CREATE INDEX idx_dashboard_users_2 ON userspace.dashboard_user_groups ( dashboard_id );

CREATE INDEX idx_dashboard_user_groups ON userspace.dashboard_user_groups ( usergroup_id );

CREATE INDEX idx_dashboard_user_groups_0 ON userspace.dashboard_user_groups ( privilege_id );

CREATE TABLE userspace.dashboard_users ( 
	user_id              varchar(50)  NOT NULL,
	privilege_id         smallint  ,
	dashboard_id         varchar(50)  NOT NULL,
	CONSTRAINT idx_dashboard_users PRIMARY KEY ( dashboard_id, user_id )
 );

CREATE INDEX idx_dashboard_users_1 ON userspace.dashboard_users ( user_id );

CREATE INDEX idx_dashboard_users_0 ON userspace.dashboard_users ( dashboard_id );

CREATE INDEX idx_dashboard_users_5 ON userspace.dashboard_users ( privilege_id );

CREATE TABLE userspace.report_comments ( 
	report_id            varchar(50)  NOT NULL,
	reprot_comment_id    varchar(50)  NOT NULL,
	created              varchar(50)  NOT NULL,
	report_comment       text  NOT NULL,
	CONSTRAINT pk_report_coments PRIMARY KEY ( reprot_comment_id ),
	CONSTRAINT pk_report_comments UNIQUE ( report_id ) 
 );

CREATE INDEX idx_report_comments ON userspace.report_comments ( created );

CREATE TABLE userspace.report_notes ( 
	report_note_id       varchar(50)  NOT NULL,
	report_id            varchar(50)  ,
	user_id              varchar(50)  ,
	config_json          json  ,
	dashboard_id         varchar(50)  ,
	CONSTRAINT pk_report_notes PRIMARY KEY ( report_note_id )
 );

CREATE INDEX idx_report_notes ON userspace.report_notes ( report_id );

CREATE INDEX idx_report_notes_0 ON userspace.report_notes ( user_id );

CREATE INDEX idx_report_notes_1 ON userspace.report_notes ( dashboard_id );

CREATE TABLE userspace.report_user_groups ( 
	report_id            varchar(50)  NOT NULL,
	usergroup_id         varchar(50)  NOT NULL,
	privilege_id         smallint  NOT NULL,
	context_filter       json  ,
	CONSTRAINT pk_report_user_groups PRIMARY KEY ( report_id, usergroup_id )
 );

CREATE INDEX idx_report_user_groups ON userspace.report_user_groups ( report_id );

CREATE INDEX idx_report_user_groups_0 ON userspace.report_user_groups ( usergroup_id );

CREATE INDEX idx_report_user_groups_1 ON userspace.report_user_groups ( privilege_id );

CREATE TABLE userspace.report_users ( 
	report_id            varchar(50)  NOT NULL,
	user_id              varchar(50)  NOT NULL,
	privilege_id         smallint  NOT NULL,
	context_filter       json  ,
	CONSTRAINT idx_report_users PRIMARY KEY ( report_id, user_id )
 );

CREATE INDEX idx_report_users_0 ON userspace.report_users ( user_id );

CREATE OR REPLACE FUNCTION public.first_day(date)
 RETURNS date
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
  SELECT (date_trunc('MONTH', $1))::date;
$function$

CREATE OR REPLACE FUNCTION public.last_day(date)
 RETURNS date
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
  SELECT (date_trunc('MONTH', $1) + INTERVAL '1 MONTH - 1 day')::date;
$function$

CREATE OR REPLACE FUNCTION public.last_days(integer)
 RETURNS date
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
  SELECT (now()::date - ($1::text || 'day')::interval)::date;
$function$

CREATE OR REPLACE FUNCTION public.last_months(integer)
 RETURNS date
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
  SELECT (now()::date - ($1::text || 'month')::interval)::date;
$function$

CREATE OR REPLACE FUNCTION public.last_weeks(integer)
 RETURNS date
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
  SELECT (now()::date - ($1::text || 'week')::interval)::date;
$function$

CREATE OR REPLACE FUNCTION public.last_years(integer)
 RETURNS date
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
  SELECT (now()::date - ($1::text || 'year')::interval)::date;
$function$

CREATE OR REPLACE FUNCTION public.user_project_privilege(character varying)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
  SELECT CASE WHEN up.privilege_id != -1 THEN up.privilege_id
	    WHEN ugp.privlege_id IS NOT NULL THEN ugp.privlege_id
	    ELSE 4
	    END
  FROM (
    SELECT user_id, privilege_id FROM userspace.users
    WHERE user_id = $1
  ) up 
  LEFT JOIN (
    SELECT user_id, min(privilege_id) as privlege_id FROM userspace.usergroups 
    INNER JOIN userspace.usergroup_users USING(usergroup_id)
    WHERE user_id = $1
    GROUP BY user_id
  ) ugp ON up.user_id = ugp.user_id;
$function$

CREATE OR REPLACE FUNCTION get_ds_by_tbl(character varying)
  RETURNS character varying
  LANGUAGE sql
  IMMUTABLE STRICT  
AS $function$ 
 select distinct ds.dataset_id from engine.data_tbls tbls
 inner join engine.data_cols dc on tbls.tbl_id = dc.tbl_id
 inner join engine.attributes attrs on attrs.col_val_id = dc.col_id
 inner join engine.datasets ds on ds.dataset_id = attrs.dataset_id
 where tbls.tbl_id = $1 and ds.dataset_type_id != 4
$function$




ALTER TABLE engine.attributes ADD CONSTRAINT fk_data_attributes FOREIGN KEY ( attr_type_id ) REFERENCES engine.attr_type( attr_type_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.attributes ADD CONSTRAINT fk_data_attributes_col_val FOREIGN KEY ( col_val_id ) REFERENCES engine.data_cols( col_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.attributes ADD CONSTRAINT fk_data_attributes_dataset FOREIGN KEY ( dataset_id ) REFERENCES engine.datasets( dataset_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.data_cols ADD CONSTRAINT fk_data_cols FOREIGN KEY ( tbl_id ) REFERENCES engine.data_tbls( tbl_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.data_cols ADD CONSTRAINT fk_data_cols_col_datatype FOREIGN KEY ( col_datatype_id ) REFERENCES engine.col_datatype( col_datatype_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.data_cols ADD CONSTRAINT fk_data_cols_type FOREIGN KEY ( col_type_id ) REFERENCES engine.col_type( col_type_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.data_tbls_rel_cols ADD CONSTRAINT fk_data_tbls_rel_cols_tbls FOREIGN KEY ( tbl_id ) REFERENCES engine.data_tbls( tbl_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.data_tbls_rel_cols ADD CONSTRAINT fk_data_tbls_rel_cols_tbls_parent FOREIGN KEY ( parent_tbl_id ) REFERENCES engine.data_tbls( tbl_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.data_tbls_rel_cols ADD CONSTRAINT fk_data_tbls_rel_cols_cols FOREIGN KEY ( col_id ) REFERENCES engine.data_cols( col_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.data_tbls_rel_cols ADD CONSTRAINT fk_data_tbls_rel_cols_cols_parent FOREIGN KEY ( parent_col_id ) REFERENCES engine.data_cols( col_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.datasets ADD CONSTRAINT fk_datasets_type FOREIGN KEY ( dataset_type_id ) REFERENCES engine.dataset_type( dataset_type_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.denied_attribute_usergroups ADD CONSTRAINT fk_denied_attribute_usergroups FOREIGN KEY ( attr_id ) REFERENCES engine.attributes( attr_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.denied_attribute_usergroups ADD CONSTRAINT fk_denied_attribute_usergroups_usergroups FOREIGN KEY ( usergroup_id ) REFERENCES userspace.usergroups( usergroup_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.denied_attribute_users ADD CONSTRAINT fk_denied_attribute_users FOREIGN KEY ( attr_id ) REFERENCES engine.attributes( attr_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.denied_attribute_users ADD CONSTRAINT fk_denied_attribute_users_users FOREIGN KEY ( user_id ) REFERENCES userspace.users( user_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.denied_dataset_usergroups ADD CONSTRAINT fk_denied_dataset_usergroups FOREIGN KEY ( dataset_id ) REFERENCES engine.datasets( dataset_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.denied_dataset_usergroups ADD CONSTRAINT fk_denied_dataset_usergroups_users FOREIGN KEY ( usergroup_id ) REFERENCES userspace.usergroups( usergroup_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.denied_dataset_users ADD CONSTRAINT fk_denied_dataset_users FOREIGN KEY ( dataset_id ) REFERENCES engine.datasets( dataset_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.denied_dataset_users ADD CONSTRAINT fk_denied_dataset_users_users FOREIGN KEY ( user_id ) REFERENCES userspace.users( user_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.filter_type ADD CONSTRAINT fk_filter_type FOREIGN KEY ( attr_type_id ) REFERENCES engine.attr_type( attr_type_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.measures ADD CONSTRAINT fk_measures FOREIGN KEY ( tbl_id ) REFERENCES engine.data_tbls( tbl_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine.measures ADD CONSTRAINT fk_measures_measures_group FOREIGN KEY ( measures_group_id ) REFERENCES engine.measures_groups( measures_group_id );

ALTER TABLE engine_config.attributes ADD CONSTRAINT fk_data_attributes_dataset FOREIGN KEY ( dataset_id ) REFERENCES engine_config.datasets( dataset_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine_config.attributes ADD CONSTRAINT fk_data_attributes FOREIGN KEY ( attr_type_id ) REFERENCES engine.attr_type( attr_type_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine_config.data_cols ADD CONSTRAINT fk_data_cols FOREIGN KEY ( tbl_id ) REFERENCES engine_config.data_tbls( tbl_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine_config.data_cols ADD CONSTRAINT fk_data_cols_col_datatype FOREIGN KEY ( col_datatype_id ) REFERENCES engine.col_datatype( col_datatype_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine_config.data_cols ADD CONSTRAINT fk_data_cols_type FOREIGN KEY ( col_type_id ) REFERENCES engine.col_type( col_type_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine_config.data_tbls_rel_cols ADD CONSTRAINT fk_data_tbls_rel_cols_tbls FOREIGN KEY ( tbl_id ) REFERENCES engine_config.data_tbls( tbl_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine_config.data_tbls_rel_cols ADD CONSTRAINT fk_data_tbls_rel_cols_tbls_parent FOREIGN KEY ( parent_tbl_id ) REFERENCES engine_config.data_tbls( tbl_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE engine_config.datasets ADD CONSTRAINT datasets_file_id_fkey FOREIGN KEY ( file_id ) REFERENCES engine_config.files( file_id );

ALTER TABLE engine_config.datasets ADD CONSTRAINT fk_datasets_type FOREIGN KEY ( dataset_type_id ) REFERENCES engine.dataset_type( dataset_type_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "public".auth_cas ADD CONSTRAINT auth_cas_user_id_fkey FOREIGN KEY ( user_id ) REFERENCES "public".auth_user( id ) ON DELETE CASCADE;

ALTER TABLE "public".auth_event ADD CONSTRAINT auth_event_user_id_fkey FOREIGN KEY ( user_id ) REFERENCES "public".auth_user( id ) ON DELETE CASCADE;

ALTER TABLE "public".auth_membership ADD CONSTRAINT auth_membership_group_id_fkey FOREIGN KEY ( group_id ) REFERENCES "public".auth_group( id ) ON DELETE CASCADE;

ALTER TABLE "public".auth_membership ADD CONSTRAINT auth_membership_user_id_fkey FOREIGN KEY ( user_id ) REFERENCES "public".auth_user( id ) ON DELETE CASCADE;

ALTER TABLE "public".auth_permission ADD CONSTRAINT auth_permission_group_id_fkey FOREIGN KEY ( group_id ) REFERENCES "public".auth_group( id ) ON DELETE CASCADE;

ALTER TABLE "public".scheduler_run ADD CONSTRAINT scheduler_run_task_id_fkey FOREIGN KEY ( task_id ) REFERENCES "public".scheduler_task( id ) ON DELETE CASCADE;

ALTER TABLE "public".scheduler_task_deps ADD CONSTRAINT scheduler_task_deps_task_child_fkey FOREIGN KEY ( task_child ) REFERENCES "public".scheduler_task( id ) ON DELETE CASCADE;

ALTER TABLE userspace.dashboard_filters ADD CONSTRAINT fk_dashboard_filters FOREIGN KEY ( dashboard_id ) REFERENCES userspace.dashboards( dashboard_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.dashboard_report_filters ADD CONSTRAINT fk_reports FOREIGN KEY ( report_id ) REFERENCES userspace.reports( report_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.dashboard_report_filters ADD CONSTRAINT fk_dashboard_report_filters FOREIGN KEY ( dashboard_filter_id ) REFERENCES userspace.dashboard_filters( dashboard_filter_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.dashboard_reports ADD CONSTRAINT fk_dashboard_reports FOREIGN KEY ( dashboard_id ) REFERENCES userspace.dashboards( dashboard_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.dashboard_reports ADD CONSTRAINT fk_dashboard_reports_0 FOREIGN KEY ( report_id ) REFERENCES userspace.reports( report_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.dashboard_user_groups ADD CONSTRAINT fk_dashboard_user_groups_dashboard FOREIGN KEY ( dashboard_id ) REFERENCES userspace.dashboards( dashboard_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.dashboard_user_groups ADD CONSTRAINT fk_dashboard_user_groups_privileges FOREIGN KEY ( privilege_id ) REFERENCES userspace."privileges"( privilege_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.dashboard_user_groups ADD CONSTRAINT fk_dashboard_user_groups_authgroup FOREIGN KEY ( usergroup_id ) REFERENCES userspace.usergroups( usergroup_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.dashboard_users ADD CONSTRAINT fk_dashboard_users_dashboards FOREIGN KEY ( dashboard_id ) REFERENCES userspace.dashboards( dashboard_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.dashboard_users ADD CONSTRAINT fk_dashboard_users_privileges FOREIGN KEY ( privilege_id ) REFERENCES userspace."privileges"( privilege_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.dashboard_users ADD CONSTRAINT fk_dashboard_users_auth_user FOREIGN KEY ( user_id ) REFERENCES userspace.users( user_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.dashboards ADD CONSTRAINT fk_dashboards_status FOREIGN KEY ( status_id ) REFERENCES userspace.status( status_id );

ALTER TABLE userspace.dashboards ADD CONSTRAINT dashboards_dashboards_group_id_fkey FOREIGN KEY ( dashboards_group_id ) REFERENCES userspace.dashboards_groups( dashboards_group_id );

ALTER TABLE userspace.measure_user_groups ADD CONSTRAINT fk_measure_user_groups_measures FOREIGN KEY ( measure_id ) REFERENCES engine.measures( measure_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.measure_user_groups ADD CONSTRAINT fk_measure_user_groups_privileges FOREIGN KEY ( privilege_id ) REFERENCES userspace."privileges"( privilege_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.measure_user_groups ADD CONSTRAINT fk_measure_user_groups_authgroup FOREIGN KEY ( usergroup_id ) REFERENCES userspace.usergroups( usergroup_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.measure_users ADD CONSTRAINT fk_measures_users_measures FOREIGN KEY ( measure_id ) REFERENCES engine.measures( measure_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.measure_users ADD CONSTRAINT fk_measures_users_auth_user FOREIGN KEY ( user_id ) REFERENCES userspace.users( user_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.notes ADD CONSTRAINT fk_notes_dashboards FOREIGN KEY ( dashboard_id ) REFERENCES userspace.dashboards( dashboard_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.notes ADD CONSTRAINT fk_notes_auth_user FOREIGN KEY ( user_id ) REFERENCES userspace.users( user_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.report_comments ADD CONSTRAINT fk_report_comments FOREIGN KEY ( report_id ) REFERENCES userspace.reports( report_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.report_notes ADD CONSTRAINT fk_report_notes_reports FOREIGN KEY ( report_id ) REFERENCES userspace.reports( report_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.report_notes ADD CONSTRAINT fk_report_notes_dashboards FOREIGN KEY ( dashboard_id ) REFERENCES userspace.dashboards( dashboard_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.report_notes ADD CONSTRAINT fk_report_notes_auth_user FOREIGN KEY ( user_id ) REFERENCES userspace.users( user_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.report_user_groups ADD CONSTRAINT fk_report_user_groups_reports FOREIGN KEY ( report_id ) REFERENCES userspace.reports( report_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.report_user_groups ADD CONSTRAINT fk_report_user_groups_privileges FOREIGN KEY ( privilege_id ) REFERENCES userspace."privileges"( privilege_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.report_user_groups ADD CONSTRAINT fk_report_user_groups_auth_group FOREIGN KEY ( usergroup_id ) REFERENCES userspace.usergroups( usergroup_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.report_users ADD CONSTRAINT fk_report_users_reports FOREIGN KEY ( report_id ) REFERENCES userspace.reports( report_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.report_users ADD CONSTRAINT fk_report_users_privileges FOREIGN KEY ( privilege_id ) REFERENCES userspace."privileges"( privilege_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.report_users ADD CONSTRAINT fk_report_users_auth_user FOREIGN KEY ( user_id ) REFERENCES userspace.users( user_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.reports ADD CONSTRAINT fk_reports_reports_groups FOREIGN KEY ( reports_group_id ) REFERENCES userspace.reports_groups( reports_group_id );

ALTER TABLE userspace.reports ADD CONSTRAINT fk_reports_status FOREIGN KEY ( status_id ) REFERENCES userspace.status( status_id );

ALTER TABLE userspace.user_filter_cache ADD CONSTRAINT user_filter_cache_cache_type_id_fkey FOREIGN KEY ( cache_type_id ) REFERENCES userspace.user_filter_cache_type( cache_type_id );

ALTER TABLE userspace.user_tabs ADD CONSTRAINT fk_user_tabs_dashboards FOREIGN KEY ( dashboard_id ) REFERENCES userspace.dashboards( dashboard_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.user_tabs ADD CONSTRAINT fk_user_tabs_reports FOREIGN KEY ( report_id ) REFERENCES userspace.reports( report_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.user_tabs ADD CONSTRAINT fk_user_tabs_auth_user FOREIGN KEY ( user_id ) REFERENCES userspace.users( user_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.usergroup_users ADD CONSTRAINT fk_usergroup_users_usergroups FOREIGN KEY ( usergroup_id ) REFERENCES userspace.usergroups( usergroup_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.usergroup_users ADD CONSTRAINT fk_usergroup_users_users FOREIGN KEY ( user_id ) REFERENCES userspace.users( user_id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE userspace.users ADD CONSTRAINT fk_users_privileges FOREIGN KEY ( privilege_id ) REFERENCES userspace."privileges"( privilege_id ) ON DELETE CASCADE ON UPDATE CASCADE;

INSERT INTO engine.attr_type(attr_type_id, attr_type_descr)  VALUES (1, 'standard');
INSERT INTO engine.attr_type(attr_type_id, attr_type_descr)  VALUES (2, 'fact');
INSERT INTO engine.attr_type(attr_type_id, attr_type_descr)  VALUES (3, 'year');
INSERT INTO engine.attr_type(attr_type_id, attr_type_descr)  VALUES (4, 'quarter');
INSERT INTO engine.attr_type(attr_type_id, attr_type_descr)  VALUES (5, 'month');
INSERT INTO engine.attr_type(attr_type_id, attr_type_descr)  VALUES (6, 'day');
INSERT INTO engine.attr_type(attr_type_id, attr_type_descr)  VALUES (7, 'date');
INSERT INTO engine.attr_type(attr_type_id, attr_type_descr)  VALUES (8,'yearquarter');
INSERT INTO engine.attr_type(attr_type_id, attr_type_descr)  VALUES (9,'yearmonth');
INSERT INTO engine.attr_type(attr_type_id, attr_type_descr)  VALUES (10,'yearweek');
INSERT INTO engine.attr_type(attr_type_id, attr_type_descr)  VALUES (11,'hour');
INSERT INTO engine.attr_type(attr_type_id, attr_type_descr)  VALUES (12,'week');

INSERT INTO engine.col_datatype(col_datatype_id, col_datatype_descr) VALUES (1,'int');
INSERT INTO engine.col_datatype(col_datatype_id, col_datatype_descr) VALUES (2,'text');
INSERT INTO engine.col_datatype(col_datatype_id, col_datatype_descr) VALUES (3,'real');
INSERT INTO engine.col_datatype(col_datatype_id, col_datatype_descr) VALUES (4,'double');
INSERT INTO engine.col_datatype(col_datatype_id, col_datatype_descr) VALUES (5,'bigint');
INSERT INTO engine.col_datatype(col_datatype_id, col_datatype_descr) VALUES (6,'date');
INSERT INTO engine.col_datatype(col_datatype_id, col_datatype_descr) VALUES (7,'timestamp');
INSERT INTO engine.col_datatype(col_datatype_id, col_datatype_descr) VALUES (8,'timestamp with time zone');

INSERT INTO engine.col_type(col_type_id, col_type_descr) VALUES (1,'pk');
INSERT INTO engine.col_type(col_type_id, col_type_descr) VALUES (2,'fk');
INSERT INTO engine.col_type(col_type_id, col_type_descr) VALUES (3,'fact');
INSERT INTO engine.col_type(col_type_id, col_type_descr) VALUES (4,'attr');
INSERT INTO engine.col_type(col_type_id, col_type_descr) VALUES (5,'date');
INSERT INTO engine.col_type(col_type_id, col_type_descr) VALUES (6,'ignore');

INSERT INTO engine.dataset_type(dataset_type_id, dataset_type_descr) VALUES (1,'fact');
INSERT INTO engine.dataset_type(dataset_type_id, dataset_type_descr) VALUES (2,'attr');
INSERT INTO engine.dataset_type(dataset_type_id, dataset_type_descr) VALUES (3,'snapshot');
INSERT INTO engine.dataset_type(dataset_type_id, dataset_type_descr) VALUES (4,'time');

INSERT INTO engine.filter_type(filter_type_id, filter_name,  formula, attr_type_id)    VALUES (1, 'Values', 'tbl.attr IN (${val_array})', 1);
INSERT INTO engine.filter_type(filter_type_id, filter_name,  formula, attr_type_id)    VALUES (2, 'Range', 'tbl.attr between ${var1} and ${var2}', 1);
INSERT INTO engine.filter_type(filter_type_id, filter_name,  formula, attr_type_id)    VALUES (3, 'Less Than', 'tbl.attr < ${var1}', 1);
INSERT INTO engine.filter_type(filter_type_id, filter_name,  formula, attr_type_id)    VALUES (4, 'Greater Than', 'tbl.attr > ${var1}', 1);
INSERT INTO engine.filter_type(filter_type_id, filter_name,  formula, attr_type_id)    VALUES (5,'Last Year','tbl.attr =  extract(year from (now() - interval ''${var1} year''))',3);
INSERT INTO engine.filter_type(filter_type_id, filter_name,  formula, attr_type_id)    VALUES (6,'Next Year','tbl.attr =  extract(year from (now() + interval ''${var1} year''))',3);
INSERT INTO engine.filter_type(filter_type_id, filter_name,  formula, attr_type_id)    VALUES (7,'Last Year Month','tbl.attr = (extract(year from (now() - interval ''${var1} month''))*100 + extract(month from (now() - interval ''${var1} month'')))',5);
INSERT INTO engine.filter_type(filter_type_id, filter_name,  formula, attr_type_id)    VALUES (8,'Next Year Month','tbl.attr = (extract(year from (now() + interval ''${var1} month''))*100 + extract(month from (now() + interval ''${var1} month'')))',5);
INSERT INTO engine.filter_type(filter_type_id, filter_name,  formula, attr_type_id)    VALUES (9,'Last Year Week','tbl.attr = (extract(year from (now() - interval ''${var1} week''))*100 + extract(week from (now() - interval ''${var1} week'')))',6);
INSERT INTO engine.filter_type(filter_type_id, filter_name,  formula, attr_type_id)    VALUES (10,'Next Year Week','tbl.attr = (extract(year from (now() - interval ''${var1} week''))*100 + extract(week from (now() - interval ''${var1} week'')))',6);
INSERT INTO engine.filter_type(filter_type_id, filter_name,  formula, attr_type_id)    VALUES (11,'Year','extract(year from ${date}) ${opr} extract(year from (now() ${var2} interval ''${var1} year''))',3);
INSERT INTO engine.filter_type(filter_type_id, filter_name,  formula, attr_type_id)    VALUES (12,'Month','(extract(year from ${date})*100 + extract(month from ${date})) ${opr} (extract(year from (now() ${var2} interval ''${var1} month''))*100 + extract(month from (now() ${var2} interval ''${var1} month'')))',5);
INSERT INTO engine.filter_type(filter_type_id, filter_name,  formula, attr_type_id)    VALUES (13,'Week','(extract(year from ${date})*100 + extract(week from ${date})) ${opr} (extract(year from (now() ${var2} interval ''${var1} week''))*100 + extract(week from (now() ${var2} interval ''${var1} week'')))',6);
INSERT INTO engine.filter_type(filter_type_id, filter_name,  formula, attr_type_id)    VALUES (14,'Last Date','tbl.attr >=  (now()::date - interval ''${var1} day'')::date',7);

INSERT INTO engine.timedimension_definitions(variable, formula, descr) VALUES ('#date','#col#::date','date');
INSERT INTO engine.timedimension_definitions(variable, formula, descr) VALUES ('#hour','extract (HOUR from #col#)::int','hour');
INSERT INTO engine.timedimension_definitions(variable, formula, descr) VALUES ('#month','extract (MONTH from #col#)::int','month');
INSERT INTO engine.timedimension_definitions(variable, formula, descr) VALUES ('#quarter','extract(QUARTER from #col#)::int','quarter');
INSERT INTO engine.timedimension_definitions(variable, formula, descr) VALUES ('#week','extract(WEEK from #col#)::int','week');
INSERT INTO engine.timedimension_definitions(variable, formula, descr) VALUES ('#year','extract(YEAR from #col#)::int','year');
INSERT INTO engine.timedimension_definitions(variable, formula, descr) VALUES ('#yearmonth','(extract(YEAR from #col#)*100+extract(MONTH from #col#))::int','yearmonth');
INSERT INTO engine.timedimension_definitions(variable, formula, descr) VALUES ('#yearquarter','(extract(YEAR from #col#)*100+extract(QUARTER from #col#))::int','yearquarter');
INSERT INTO engine.timedimension_definitions(variable, formula, descr) VALUES ('#yearweek','(extract(YEAR from #col#)*100+extract(WEEK from #col#))::int','yearweek');

INSERT INTO userspace.privileges(privilege_id, privilege_descr) VALUES (-1,'Driven by group');
INSERT INTO userspace.privileges(privilege_id, privilege_descr) VALUES (1,'Full Control');
INSERT INTO userspace.privileges(privilege_id, privilege_descr) VALUES (2,'Edit Content');
INSERT INTO userspace.privileges(privilege_id, privilege_descr) VALUES (3,'View Content');
INSERT INTO userspace.privileges(privilege_id, privilege_descr) VALUES (4,'No Access');

INSERT INTO userspace.status(status_id, status_descr) VALUES (0, 'empty');
INSERT INTO userspace.status(status_id, status_descr) VALUES (1, 'draft');
INSERT INTO userspace.status(status_id, status_descr) VALUES (2, 'ready');
INSERT INTO userspace.status(status_id, status_descr) VALUES (3, 'edit');
INSERT INTO userspace.status(status_id, status_descr) VALUES (4, 'drill');

INSERT INTO userspace.user_filter_cache_type(cache_type_id, cache_type_descr) VALUES (1, 'context filter');
INSERT INTO userspace.user_filter_cache_type(cache_type_id, cache_type_descr) VALUES (2, 'dashboard filter');

INSERT INTO maintenance.error_source(source_id, source_name) VALUES (1, 'server');
INSERT INTO maintenance.error_source(source_id, source_name) VALUES (2, 'frontend');

INSERT INTO engine.measures_groups(measures_group_id, measures_group_name) VALUES ('b0c5a21b734b4daff84fa1609a0b3de0', 'Unsorted');

INSERT INTO userspace.reports_groups(reports_group_id, reports_group_name) VALUES ('b0c5a21b734b4daff84fa1609a0b3de0', 'Unsorted');

INSERT INTO userspace.dashboards_groups(dashboards_group_id, dashboards_group_name) VALUES ('b0c5a21b734b4daff84fa1609a0b3de0', 'Unsorted');

INSERT INTO userspace.reports(report_id, report_name)   VALUES ('empty', 'empty');

INSERT INTO userspace.dashboards(dashboard_id, dashboard_name)   VALUES ('empty', 'empty');





