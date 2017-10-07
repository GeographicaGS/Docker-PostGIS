/* 

  Proj.4 test.

*/

begin;

/*
  Test transformations
*/
create or replace function public.gs__test_grid_proj4()
returns boolean as
$$
declare
  _sql text;
  _p geometry;
  _tp geometry;
  _t23030x numeric=235205.243;
  _t23030y numeric=4142110.093;
  _t25830x numeric=265353.396;
  _t25830y numeric=3987805.481;
  _t4230x numeric=-5.990770927777778;
  _t4230y numeric=37.387348808333336;
begin
	-- 25830 to 23030
  _p = st_setsrid(st_makepoint(235094, 4141906), 25830);
  _tp = st_transform(_p, 23030);

  if not round(st_x(_tp)::numeric,3) between _t23030x-0.001 and _t23030x+0.001 then
	  raise notice 'Transformation from 25830 to 23030 failed: got % for x, should be ~%', st_x(_tp),
		  _t23030x::text;
	  return false;
  else
    raise notice 'Transformation from 25830 to 23030 successfull: got % for x, should be ~%', st_x(_tp), 
		  _t23030x::text;
  end if;

  if not round(st_y(_tp)::numeric,3) between _t23030y-0.001 and _t23030y+0.001 then
	  raise notice 'Transformation from 25830 to 23030 failed: got % for y, should be ~%', st_y(_tp),
		  _t23030y::text;
	  return false;
  else
    raise notice 'Transformation from 25830 to 23030 successfull: got % for y, should be ~%', st_y(_tp), 
		  _t23030y::text;
  end if;

  -- 23030 to 25830
  _p = st_setsrid(st_makepoint(265467, 3988010), 23030);
  _tp = st_transform(_p, 25830);

  if not round(st_x(_tp)::numeric,3) between _t25830x-0.001 and _t25830x+0.001 then
	  raise notice 'Transformation from 23030 to 25830 failed: got % for x, should be ~%', st_x(_tp),
		  _t25830x::text;
	  return false;
  else
    raise notice 'Transformation from 23030 to 25830 successfull: got % for x, should be ~%', st_x(_tp),
		  _t25830x::text;
  end if;

  if not round(st_y(_tp)::numeric,3) between _t25830y-0.001 and _t25830y+0.001 then
	  raise notice 'Transformation from 23030 to 25830 failed: got % for y, should be ~%', st_y(_tp),
		  _t25830y::text;
	  return false;
  else
    raise notice 'Transformation from 23030 to 25830 successfull: got % for y, should be ~%', st_y(_tp), 
		  _t25830y::text;
  end if;

  -- 4326 to 4230
  _p = st_setsrid(st_makepoint(-5.992110363888889, 37.38608963055555), 4326);
  _tp = st_transform(_p, 4230);

  if not st_x(_tp) between _t4230x-0.00001 and _t4230x+0.00001 then
	  raise notice 'Transformation from 4326 to 4230 failed: got % for x, should be ~%', st_x(_tp), _t4230x::text;
	  return false;
  else
    raise notice 'Transformation from 4326 to 4230 successfull: got % for x, should be ~%', st_x(_tp), 
		  _t4230x::text;
  end if;

  if not st_y(_tp) between _t4230y-0.00001 and _t4230y+0.00001 then
	  raise notice 'Transformation from 4326 to 4230 failed: got % for y, should be ~%', st_y(_tp), _t4230y::text;
	  return false;
  else
    raise notice 'Transformation from 4326 to 4230 successfull: got % for y, should be ~%', st_y(_tp),
		  _t4230y::text;
  end if;

  return true;
end;
$$
language plpgsql;

\echo Testing proj4 NTV2 support for Spain...

select public.gs__test_grid_proj4();

commit;
