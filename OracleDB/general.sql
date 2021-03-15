alter session set nls_language = english; 

alter session enable parallel dml;
alter session disable parallel dml;

insert /* + enable_parallel_dml parallel*/ into destination select * from source;
insert /* + disable_parallel_dml parallel*/ into destination select * from source;

