/* ags--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION ags" to load this file. \quit

CREATE FUNCTION agshandler(internal)
RETURNS index_am_handler
AS 'MODULE_PATHNAME'
LANGUAGE C;

-- Access method
CREATE ACCESS METHOD ags TYPE INDEX HANDLER agshandler;
COMMENT ON ACCESS METHOD ags IS 'ags index access method';

CREATE OPERATOR CLASS ags_cube_ops
    DEFAULT FOR TYPE cube USING ags AS
	OPERATOR	3	&& ,
	OPERATOR	6	= ,
	OPERATOR	7	@> ,
	OPERATOR	8	<@ ,
	OPERATOR	13	@ ,
	OPERATOR	14	~ ,
	OPERATOR	15	~> (cube, int) FOR ORDER BY float_ops,
	OPERATOR	16	<#> (cube, cube) FOR ORDER BY float_ops,
	OPERATOR	17	<-> (cube, cube) FOR ORDER BY float_ops,
	OPERATOR	18	<=> (cube, cube) FOR ORDER BY float_ops,

	FUNCTION	1	g_cube_consistent (internal, cube, smallint, oid, internal),
	FUNCTION	2	g_cube_union (internal, internal),
	FUNCTION	5	g_cube_penalty (internal, internal, internal),
	FUNCTION	6	g_cube_picksplit (internal, internal),
	FUNCTION	7	g_cube_same (cube, cube, internal),
	FUNCTION	8	g_cube_distance (internal, cube, smallint, oid, internal);

