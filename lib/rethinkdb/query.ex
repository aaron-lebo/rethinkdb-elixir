defmodule RethinkDB.Query do
  alias RethinkDB.Q

  require RethinkDB.Query.Macros
  import RethinkDB.Query.Macros

  @type t :: %Q{}
  @type reql_string :: String.t|t
  @type reql_number :: integer|float|t
  @type reql_array  :: [term]|t
  @type reql_bool   :: boolean|t
  @type reql_obj    :: %{}|t
  @type reql_datum  :: term
  @type reql_func0  :: (() -> term)|t
  @type reql_func1  :: (term -> term)|t
  @type reql_func2  :: (term, term -> term)|t
  @type reql_opts   :: %{}
  @type reql_binary :: %RethinkDB.Pseudotypes.Binary{}|binary|t
  @type reql_geo_point    :: %RethinkDB.Pseudotypes.Geometry.Point{}|{reql_number,reql_number}|t
  @type reql_geo_line     :: %RethinkDB.Pseudotypes.Geometry.Line{}|t
  @type reql_geo_polygon  :: %RethinkDB.Pseudotypes.Geometry.Polygon{}|t
  @type reql_geo    :: reql_geo_point|reql_geo_line|reql_geo_polygon

  """
  Aggregation Functions
  """

  @doc """
  Takes a stream and partitions it into multiple groups based on the fields or 
  functions provided.

  With the multi flag single documents can be assigned to multiple groups, 
  similar to the behavior of multi-indexes. When multi is True and the grouping 
  value is an array, documents will be placed in each group that corresponds to 
  the elements of the array. If the array is empty the row will be ignored.
  """
  @spec group(Q.reql_array, Q.reql_func1 | Q.reql_string | [Q.reql_func1 | Q.reql_string] ) :: Q.t
  def group(seq, keys) when is_list(keys), do: %Q{query: [144, [wrap(seq) | Enum.map(keys, &wrap/1)]]}
  def group(seq, key), do: group(seq, [key])

  @doc """
  Takes a grouped stream or grouped data and turns it into an array of objects 
  representing the groups. Any commands chained after ungroup will operate on 
  this array, rather than operating on each group individually. This is useful if 
  you want to e.g. order the groups by the value of their reduction.

  The format of the array returned by ungroup is the same as the default native 
  format of grouped data in the JavaScript driver and data explorer.
  end
  """
  @spec ungroup(Q.t) :: Q.t
  operate_on_single_arg(:ungroup, 150)

  @doc """
  Produce a single value from a sequence through repeated application of a 
  reduction function.

  The reduction function can be called on:

  * two elements of the sequence
  * one element of the sequence and one result of a previous reduction
  * two results of previous reductions

  The reduction function can be called on the results of two previous 
  reductions because the reduce command is distributed and parallelized across 
  shards and CPU cores. A common mistaken when using the reduce command is to 
  suppose that the reduction is executed from left to right.
  """
  @spec reduce(Q.reql_array, Q.reql_func2) :: Q.t
  operate_on_two_args(:reduce, 37)

  @doc """
  Counts the number of elements in a sequence. If called with a value, counts 
  the number of times that value occurs in the sequence. If called with a 
  predicate function, counts the number of elements in the sequence where that 
  function returns `true`.

  If count is called on a binary object, it will return the size of the object 
  in bytes.
  """
  @spec count(Q.reql_array) :: Q.t
  operate_on_single_arg(:count, 43)
  @spec count(Q.reql_array, Q.reql_string | Q.reql_func1) :: Q.t
  operate_on_two_args(:count, 43)
 
  @doc """
  Sums all the elements of a sequence. If called with a field name, sums all 
  the values of that field in the sequence, skipping elements of the sequence 
  that lack that field. If called with a function, calls that function on every 
  element of the sequence and sums the results, skipping elements of the sequence 
  where that function returns `nil` or a non-existence error.

  Returns 0 when called on an empty sequence.
  """
  @spec sum(Q.reql_array) :: Q.t
  operate_on_single_arg(:sum, 145)
  @spec sum(Q.reql_array, Q.reql_string|Q.reql_func1) :: Q.t
  operate_on_two_args(:sum, 145)

  @doc """
  Averages all the elements of a sequence. If called with a field name, 
  averages all the values of that field in the sequence, skipping elements of the 
  sequence that lack that field. If called with a function, calls that function 
  on every element of the sequence and averages the results, skipping elements of 
  the sequence where that function returns None or a non-existence error.

  Produces a non-existence error when called on an empty sequence. You can 
  handle this case with `default`.
  """
  @spec avg(Q.reql_array) :: Q.t
  operate_on_single_arg(:avg, 146)
  @spec avg(Q.reql_array, Q.reql_string|Q.reql_func1) :: Q.t
  operate_on_two_args(:avg, 146)

  @doc """
  Finds the minimum element of a sequence. The min command can be called with:

  * a field name, to return the element of the sequence with the smallest value in 
  that field;
  * an index, to return the element of the sequence with the smallest value in that 
  index;
  * a function, to apply the function to every element within the sequence and 
  return the element which returns the smallest value from the function, ignoring 
  any elements where the function returns None or produces a non-existence error.

  Calling min on an empty sequence will throw a non-existence error; this can be 
  handled using the `default` command.
  """
  @spec min(Q.reql_array, Q.reql_opts | Q.reql_string | Q.reql_func1) :: Q.t
  def min(seq, opts) when is_map(opts), do: %Q{query: [147, [wrap(seq)], opts]}
  operate_on_single_arg(:min, 147)
  operate_on_two_args(:min, 147)

  @doc """
  Finds the maximum element of a sequence. The max command can be called with:

  * a field name, to return the element of the sequence with the smallest value in 
  that field;
  * an index, to return the element of the sequence with the smallest value in that 
  index;
  * a function, to apply the function to every element within the sequence and 
  return the element which returns the smallest value from the function, ignoring 
  any elements where the function returns None or produces a non-existence error.

  Calling max on an empty sequence will throw a non-existence error; this can be 
  handled using the `default` command.
  """
  @spec max(Q.reql_array, Q.reql_opts | Q.reql_string | Q.reql_func1) :: Q.t
  def max(seq, opts) when is_map(opts), do: %Q{query: [148, [wrap(seq)], opts]}
  operate_on_single_arg(:max, 148)
  operate_on_two_args(:max, 148)

  @doc """
  Removes duplicates from elements in a sequence.

  The distinct command can be called on any sequence, a table, or called on a 
  table with an index.
  """
  @spec distinct(Q.reql_array, Q.reql_opts) :: Q.t
  def distinct(seq, opts) when is_map(opts), do: %Q{query: [42, [wrap(seq)], opts]}
  operate_on_single_arg(:distinct, 42)

  @doc """
  When called with values, returns `true` if a sequence contains all the specified 
  values. When called with predicate functions, returns `true` if for each 
  predicate there exists at least one element of the stream where that predicate 
  returns `true`.
  """
  @spec contains(Q.reql_array, Q.reql_array | Q.reql_func1 | Q.t) :: Q.t
  operate_on_seq_and_list(:contains, 93)
  operate_on_two_args(:contains, 93)

  """
  Control Strucutres
  """
  @doc """
  `args` is a special term that’s used to splice an array of arguments into 
  another term. This is useful when you want to call a variadic term such as 
  `get_all` with a set of arguments produced at runtime.

  This is analogous to Elixir's `apply`.
  """
  @spec args(Q.reql_array) :: Q.t
  operate_on_single_arg(:args, 154)

  @doc """
  Encapsulate binary data within a query.

  Only a limited subset of ReQL commands may be chained after binary:

  * coerce_to can coerce binary objects to string types
  * count will return the number of bytes in the object
  * slice will treat bytes like array indexes (i.e., slice(10,20) will return bytes 
  * 10–19)
  * type_of returns PTYPE<BINARY>
  * info will return information on a binary object.
  """
  @spec binary(Q.reql_binary) :: Q.t
  def binary(%RethinkDB.Pseudotypes.Binary{data: data}), do: binary(data)
  operate_on_single_arg(:binary, 155)

  @doc """
  Call an anonymous function using return values from other ReQL commands or 
  queries as arguments.

  The last argument to do (or, in some forms, the only argument) is an expression 
  or an anonymous function which receives values from either the previous 
  arguments or from prefixed commands chained before do. The do command is 
  essentially a single-element map, letting you map a function over just one 
  document. This allows you to bind a query result to a local variable within the 
  scope of do, letting you compute the result just once and reuse it in a complex 
  expression or in a series of ReQL commands.

  Arguments passed to the do function must be basic data types, and cannot be 
  streams or selections. (Read about ReQL data types.) While the arguments will 
  all be evaluated before the function is executed, they may be evaluated in any 
  order, so their values should not be dependent on one another. The type of do’s 
  result is the type of the value returned from the function or last expression.
  """
  @spec do_r(Q.reql_datum | Q.reql_func0, Q.reql_func1) :: Q.t
  operate_on_single_arg(:do_r, 64)
  def do_r(data, f) when is_function(f), do: %Q{query: [64, [wrap(f), wrap(data)]]}

  @doc """
  If the `test` expression returns False or None, the false_branch will be 
  evaluated. Otherwise, the true_branch will be evaluated.

  The branch command is effectively an if renamed due to language constraints.
  """
  @spec branch(Q.reql_datum, Q.reql_datum, Q.reql_datum) :: Q.t
  def branch(test, true_branch, false_branch) do
    %Q{query: [65, [wrap(test), wrap(true_branch), wrap(false_branch)]]}
  end

  @doc """
  Loop over a sequence, evaluating the given write query for each element.
  """
  @spec for_each(Q.reql_array, Q.reql_func1) :: Q.t
  operate_on_two_args(:for_each, 68)

  @doc """
  Throw a runtime error.
  """
  @spec error(Q.reql_string) :: Q.t
  operate_on_single_arg(:error, 12)

  @doc """
  Handle non-existence errors. Tries to evaluate and return its first argument. 
  If an error related to the absence of a value is thrown in the process, or if 
  its first argument returns nil, returns its second argument. (Alternatively, 
  the second argument may be a function which will be called with either the text 
  of the non-existence error or nil.)
  """
  @spec default(Q.t, Q.t) :: Q.t
  operate_on_two_args(:default, 92)

  @doc """
  Create a javascript expression.

  `timeout` is the number of seconds before `js` times out. The default value 
  is 5 seconds.
  """
  @spec js(Q.reql_string, Q.reql_number) :: Q.t
  operate_on_single_arg(:js, 11)
  def js(javascript, number), do: %Q{query: [11, [wrap(javascript)], %{timeout: number}]}

  @doc """
  Convert a value of one type into another.

  * a sequence, selection or object can be coerced to an array
  * an array of key-value pairs can be coerced to an object
  * a string can be coerced to a number
  * any datum (single value) can be coerced to a string
  * a binary object can be coerced to a string and vice-versa
  """
  @spec coerce_to(Q.reql_datum, Q.reql_string) :: Q.t
  operate_on_two_args(:coerce_to, 51)

  @doc """
  Gets the type of a value.
  """
  @spec type_of(Q.reql_datum) :: Q.t
  operate_on_single_arg(:type_of, 52)

  @doc """
  Get information about a ReQL value.
  """
  @spec info(Q.t) :: Q.t
  operate_on_single_arg(:info, 79)

  @doc """
  Parse a JSON string on the server.
  """
  @spec json(Q.reql_string) :: Q.t
  operate_on_single_arg(:json, 98)

  @doc """
  Retrieve data from the specified URL over HTTP. The return type depends on 
  the result_format option, which checks the Content-Type of the response by 
  default.
  """
  @spec http(Q.reql_string, Q.reql_obj) :: Q.t
  def http(url, opts \\ %{}), do: %Q{query: [153, [url], opts]}

  @doc """
  Return a UUID (universally unique identifier), a string that can be used as a unique ID.
  """
  @spec uuid() :: Q.t
  operate_on_zero_args(:uuid, 169)

  """
  Database Operations
  """

  @doc """
  Create a database. A RethinkDB database is a collection of tables, similar to 
  relational databases.

  If successful, the command returns an object with two fields:

  * dbs_created: always 1.
  * config_changes: a list containing one object with two fields, old_val and 
    new_val:
    * old_val: always null.
    * new_val: the database’s new config value.

  If a database with the same name already exists, the command throws 
  RqlRuntimeError.

  Note: Only alphanumeric characters and underscores are valid for the database 
  name.
  """
  @spec db_create(Q.reql_string) :: Q.t
  operate_on_single_arg(:db_create, 57)

  @doc """
  Drop a database. The database, all its tables, and corresponding data will be deleted.

  If successful, the command returns an object with two fields:

  * dbs_dropped: always 1.
  * tables_dropped: the number of tables in the dropped database.
  * config_changes: a list containing one two-field object, old_val and new_val:
    * old_val: the database’s original config value.
    * new_val: always None.

  If the given database does not exist, the command throws RqlRuntimeError.
  """
  @spec db_drop(Q.reql_string) :: Q.t
  operate_on_single_arg(:db_drop, 58)

  @doc """
  List all database names in the system. The result is a list of strings.
  """
  @spec db_list :: Q.t
  operate_on_zero_args(:db_list, 59)

  """
  Geospatial Queries
  """

  @doc """
  Construct a circular line or polygon. A circle in RethinkDB is a polygon or 
  line approximating a circle of a given radius around a given center, consisting 
  of a specified number of vertices (default 32).

  The center may be specified either by two floating point numbers, the latitude 
  (−90 to 90) and longitude (−180 to 180) of the point on a perfect sphere (see 
  Geospatial support for more information on ReQL’s coordinate system), or by a 
  point object. The radius is a floating point number whose units are meters by 
  default, although that may be changed with the unit argument.

  Optional arguments available with circle are:

  - num_vertices: the number of vertices in the polygon or line. Defaults to 32.
  - geo_system: the reference ellipsoid to use for geographic coordinates. Possible 
  values are WGS84 (the default), a common standard for Earth’s geometry, or 
  unit_sphere, a perfect sphere of 1 meter radius.
  - unit: Unit for the radius distance. Possible values are m (meter, the default), 
  km (kilometer), mi (international mile), nm (nautical mile), ft (international 
  foot).
  - fill: if `true` (the default) the circle is filled, creating a polygon; if `false` 
  the circle is unfilled (creating a line).
  """
  @spec circle(Q.reql_geo, Q.reql_number, Q.reql_opts) :: Q.t
  operate_on_two_args(:circle, 165)

  @doc """
  Compute the distance between a point and another geometry object. At least one 
  of the geometry objects specified must be a point.

  Optional arguments available with distance are:

  - geo_system: the reference ellipsoid to use for geographic coordinates. Possible 
  values are WGS84 (the default), a common standard for Earth’s geometry, or 
  unit_sphere, a perfect sphere of 1 meter radius.
  - unit: Unit to return the distance in. Possible values are m (meter, the 
  default), km (kilometer), mi (international mile), nm (nautical mile), ft 
  (international foot).

  If one of the objects is a polygon or a line, the point will be projected onto 
  the line or polygon assuming a perfect sphere model before the distance is 
  computed (using the model specified with geo_system). As a consequence, if the 
  polygon or line is extremely large compared to Earth’s radius and the distance 
  is being computed with the default WGS84 model, the results of distance should 
  be considered approximate due to the deviation between the ellipsoid and 
  spherical models.
  """
  @spec distance(Q.reql_geo, Q.reql_geo, Q.reql_opts) :: Q.t
  operate_on_two_args(:distance, 162)

  @doc """
  Convert a Line object into a Polygon object. If the last point does not 
  specify the same coordinates as the first point, polygon will close the polygon 
  by connecting them.
  """
  @spec fill(Q.reql_line) :: Q.t
  operate_on_single_arg(:fill, 167)

  @doc """
  Convert a GeoJSON object to a ReQL geometry object.

  RethinkDB only allows conversion of GeoJSON objects which have ReQL 
  equivalents: Point, LineString, and Polygon. MultiPoint, MultiLineString, and 
  MultiPolygon are not supported. (You could, however, store multiple points, 
  lines and polygons in an array and use a geospatial multi index with them.)

  Only longitude/latitude coordinates are supported. GeoJSON objects that use 
  Cartesian coordinates, specify an altitude, or specify their own coordinate 
  reference system will be rejected.
  """
  @spec geojson(Q.reql_obj) :: Q.t
  operate_on_single_arg(:geojson, 157)

  @doc """
  Convert a ReQL geometry object to a GeoJSON object.
  """
  @spec to_geojson(Q.reql_obj) :: Q.t
  operate_on_single_arg(:to_geojson, 158)

  @doc """
  Get all documents where the given geometry object intersects the geometry 
  object of the requested geospatial index.

  The index argument is mandatory. This command returns the same results as 
  `filter(r.row('index')) |> intersects(geometry)`. The total number of results 
  is limited to the array size limit which defaults to 100,000, but can be 
  changed with the `array_limit` option to run.
  """
  @spec get_intersecting(Q.reql_array, Q.reql_geo, Q.reql_opts) :: Q.t
  operate_on_two_args(:get_intersecting, 166)

  @doc """
  Get all documents where the specified geospatial index is within a certain 
  distance of the specified point (default 100 kilometers).

  The index argument is mandatory. Optional arguments are:

  * max_results: the maximum number of results to return (default 100).
  * unit: Unit for the distance. Possible values are m (meter, the default), km 
  (kilometer), mi (international mile), nm (nautical mile), ft (international 
  foot).
  * max_dist: the maximum distance from an object to the specified point (default 
  100 km).
  * geo_system: the reference ellipsoid to use for geographic coordinates. Possible 
  values are WGS84 (the default), a common standard for Earth’s geometry, or 
  unit_sphere, a perfect sphere of 1 meter radius.

  The return value will be an array of two-item objects with the keys dist and 
  doc, set to the distance between the specified point and the document (in the 
  units specified with unit, defaulting to meters) and the document itself, 
  respectively.

  """
  @spec get_nearest(Q.reql_array, Q.reql_geo, Q.reql_opts) :: Q.t
  operate_on_two_args(:get_nearest, 168)

  @doc """
  Tests whether a geometry object is completely contained within another. When 
  applied to a sequence of geometry objects, includes acts as a filter, returning 
  a sequence of objects from the sequence that include the argument.
  """
  @spec includes(Q.reql_geo, Q.reql_geo) :: Q.t
  operate_on_two_args(:includes, 164)

  @doc """
  Tests whether two geometry objects intersect with one another. When applied to 
  a sequence of geometry objects, intersects acts as a filter, returning a 
  sequence of objects from the sequence that intersect with the argument.
  """
  @spec intersects(Q.reql_geo, Q.reql_geo) :: Q.t
  operate_on_two_args(:intersects, 163)

  @doc """
  Construct a geometry object of type Line. The line can be specified in one of 
  two ways:

  - Two or more two-item arrays, specifying latitude and longitude numbers of the 
  line’s vertices;
  - Two or more Point objects specifying the line’s vertices.
  """
  @spec line([Q.reql_geo]) :: Q.t
  operate_on_list(:line, 160)

  @doc """
  Construct a geometry object of type Point. The point is specified by two 
  floating point numbers, the longitude (−180 to 180) and latitude (−90 to 90) of 
  the point on a perfect sphere.
  """
  @spec point(Q.reql_geo) :: Q.t
  def point({la,lo}), do: point(la, lo)
  operate_on_two_args(:point, 159)

  @doc """
  Construct a geometry object of type Polygon. The Polygon can be specified in 
  one of two ways:

  Three or more two-item arrays, specifying latitude and longitude numbers of the 
  polygon’s vertices;
  * Three or more Point objects specifying the polygon’s vertices.
  * Longitude (−180 to 180) and latitude (−90 to 90) of vertices are plotted on a 
  perfect sphere. See Geospatial support for more information on ReQL’s 
  coordinate system.

  If the last point does not specify the same coordinates as the first point, 
  polygon will close the polygon by connecting them. You cannot directly 
  construct a polygon with holes in it using polygon, but you can use polygon_sub 
  to use a second polygon within the interior of the first to define a hole.
  """
  @spec polygon([Q.reql_geo]) :: Q.t
  operate_on_list(:polygon, 161)

  @doc """
  Use polygon2 to “punch out” a hole in polygon1. polygon2 must be completely 
  contained within polygon1 and must have no holes itself (it must not be the 
  output of polygon_sub itself).
  """
  @spec polygon_sub(Q.reql_geo, Q.reql_geo) :: Q.t
  operate_on_two_args(:polygon_sub, 171)

  """
  Joins Queries
  """

  @doc """
  Returns an inner join of two sequences. The returned sequence represents an
  intersection of the left-hand sequence and the right-hand sequence: each row of
  the left-hand sequence will be compared with each row of the right-hand
  sequence to find all pairs of rows which satisfy the predicate. Each matched
  pair of rows of both sequences are combined into a result row. In most cases,
  you will want to follow the join with `zip` to combine the left and right results.

  Note that `inner_join` is slower and much less efficient than using `eqJoin` or
  `flat_map` with `get_all`. You should avoid using `inner_join` in commands when
  possible.

      iex> table("people") |> inner_join(
          table("phone_numbers"), &(eq(&1["id"], &2["person_id"])
        ) |> run

  """
  @spec inner_join(Q.reql_array, Q.reql_array, Q.reql_func2) :: Q.t
  operate_on_three_args(:inner_join, 48)

  @doc """
  Returns a left outer join of two sequences. The returned sequence represents
  a union of the left-hand sequence and the right-hand sequence: all documents in
  the left-hand sequence will be returned, each matched with a document in the
  right-hand sequence if one satisfies the predicate condition. In most cases,
  you will want to follow the join with `zip` to combine the left and right results.

  Note that `outer_join` is slower and much less efficient than using `flat_map`
  with `get_all`. You should avoid using `outer_join` in commands when possible.

      iex> table("people") |> outer_join(
          table("phone_numbers"), &(eq(&1["id"], &2["person_id"])
        ) |> run

  """
  @spec outer_join(Q.reql_array, Q.reql_array, Q.reql_func2) :: Q.t
  operate_on_three_args(:outer_join, 49)

  @doc """
  Join tables using a field on the left-hand sequence matching primary keys or
  secondary indexes on the right-hand table. `eq_join` is more efficient than other
  ReQL join types, and operates much faster. Documents in the result set consist
  of pairs of left-hand and right-hand documents, matched when the field on the
  left-hand side exists and is non-null and an entry with that field’s value
  exists in the specified index on the right-hand side.

  The result set of `eq_join` is a stream or array of objects. Each object in the
  returned set will be an object of the form `{ left: <left-document>, right:
  <right-document> }`, where the values of left and right will be the joined
  documents. Use the zip command to merge the left and right fields together.

      iex> table("people") |> eq_join(
          "id", table("phone_numbers"), %{index: "person_id"}
        ) |> run

  """
  @spec eq_join(Q.reql_array, Q.reql_string, Q.reql_array, %{}) :: Q.t
  operate_on_three_args(:eq_join, 50)

  @doc """
  Used to ‘zip’ up the result of a join by merging the ‘right’ fields into
  ‘left’ fields of each member of the sequence.

      iex> table("people") |> eq_join(
          "id", table("phone_numbers"), %{index: "person_id"}
        ) |> zip |> run

  """
  @spec zip(Q.reql_array) :: Q.t
  operate_on_single_arg(:zip, 72)

  """
  Math and Logic Queries
  """

  @doc """
  Sum two numbers, concatenate two strings, or concatenate 2 arrays.

      iex> add(1, 2) |> run conn
      %RethinkDB.Record{data: 3}

      iex> add("hello", " world") |> run conn
      %RethinkDB.Record{data: "hello world"}

      iex> add([1,2], [3,4]) |> run conn
      %RethinkDB.Record{data: [1,2,3,4]}

  """
  @spec add((Q.reql_number | Q.reql_string), (Q.reql_number | Q.reql_string)) :: Q.t
  operate_on_two_args(:add, 24)

  @doc """
  Add multiple values.

      iex> add([1, 2]) |> run conn
      %RethinkDB.Record{data: 3}

      iex> add(["hello", " world"]) |> run
      %RethinkDB.Record{data: "hello world"}

  """
  @spec add([(Q.reql_number | Q.reql_string | Q.reql_array)]) :: Q.t
  operate_on_list(:add, 24)

  @doc """
  Subtract two numbers.

      iex> sub(1, 2) |> run conn
      %RethinkDB.Record{data: -1}

  """
  @spec sub(Q.reql_number, Q.reql_number) :: Q.t
  operate_on_two_args(:sub, 25)

  @doc """
  Subtract multiple values. Left associative.

      iex> sub([9, 1, 2]) |> run conn
      %RethinkDB.Record{data: 6}

  """
  @spec sub([Q.reql_number]) :: Q.t
  operate_on_list(:sub, 25)

  @doc """
  Multiply two numbers, or make a periodic array.

      iex> mul(2,3) |> run conn
      %RethinkDB.Record{data: 6}

      iex> mul([1,2], 2) |> run conn
      %RethinkDB.Record{data: [1,2,1,2]}

  """
  @spec mul((Q.reql_number | Q.reql_array), (Q.reql_number | Q.reql_array)) :: Q.t
  operate_on_two_args(:mul, 26)
  @doc """
  Multiply multiple values.

      iex> mul([2,3,4]) |> run conn
      %RethinkDB.Record{data: 24}

  """
  @spec mul([(Q.reql_number | Q.reql_array)]) :: Q.t
  operate_on_list(:mul, 26)

  @doc """
  Divide two numbers.

      iex> divide(12, 4) |> run conn
      %RethinkDB.Record{data: 3}

  """
  @spec divide(Q.reql_number, Q.reql_number) :: Q.t
  operate_on_two_args(:divide, 27)
  @doc """
  Divide a list of numbers. Left associative.

      iex> divide([12, 2, 3]) |> run conn
      %RethinkDB.Record{data: 2}

  """
  @spec divide([Q.reql_number]) :: Q.t
  operate_on_list(:divide, 27)

  @doc """
  Find the remainder when dividing two numbers.

      iex> mod(23, 4) |> run conn
      %RethinkDB.Record{data: 3}

  """
  @spec mod(Q.reql_number, Q.reql_number) :: Q.t
  operate_on_two_args(:mod, 28)

  @doc """ 
  Compute the logical “and” of two values.

      iex> and(true, true) |> run conn
      %RethinkDB.Record{data: true}

      iex> and(false, true) |> run conn
      %RethinkDB.Record{data: false}
  """
  @spec and_r(Q.reql_bool, Q.reql_bool) :: Q.t
  operate_on_two_args(:and_r, 67)
  @doc """ 
  Compute the logical “and” of all values in a list.

      iex> and_r([true, true, true]) |> run conn
      %RethinkDB.Record{data: true}

      iex> and_r([false, true, true]) |> run conn
      %RethinkDB.Record{data: false}
  """
  @spec and_r([Q.reql_bool]) :: Q.t
  operate_on_list(:and_r, 67)

  @doc """
  Compute the logical “or” of two values.

      iex> or_r(true, false) |> run conn
      %RethinkDB.Record{data: true}

      iex> or_r(false, false) |> run conn
      %RethinkDB.Record{data: false}

  """
  @spec or_r(Q.reql_bool, Q.reql_bool) :: Q.t
  operate_on_two_args(:or_r, 66)
  @doc """
  Compute the logical “or” of all values in a list.

      iex> or_r([true, true, true]) |> run conn
      %RethinkDB.Record{data: true}

      iex> or_r([false, true, true]) |> run conn
      %RethinkDB.Record{data: false}

  """
  @spec or_r([Q.reql_bool]) :: Q.t
  operate_on_list(:or_r, 66)

  @doc """
  Test if two values are equal.

      iex> eq(1,1) |> run conn
      %RethinkDB.Record{data: true}

      iex> eq(1, 2) |> run conn
      %RethinkDB.Record{data: false}
  """
  @spec eq(Q.reql_datum, Q.reql_datum) :: Q.t
  operate_on_two_args(:eq, 17)
  @doc """
  Test if all values in a list are equal.

      iex> eq([2, 2, 2]) |> run conn
      %RethinkDB.Record{data: true}

      iex> eq([2, 1, 2]) |> run conn
      %RethinkDB.Record{data: false}
  """
  @spec eq([Q.reql_datum]) :: Q.t
  operate_on_list(:eq, 17)
    
  @doc """
  Test if two values are not equal.

      iex> ne(1,1) |> run conn
      %RethinkDB.Record{data: false}

      iex> ne(1, 2) |> run conn
      %RethinkDB.Record{data: true}
  """
  @spec ne(Q.reql_datum, Q.reql_datum) :: Q.t
  operate_on_two_args(:ne, 18)
  @doc """
  Test if all values in a list are not equal.

      iex> ne([2, 2, 2]) |> run conn
      %RethinkDB.Record{data: false}

      iex> ne([2, 1, 2]) |> run conn
      %RethinkDB.Record{data: true}
  """
  @spec ne([Q.reql_datum]) :: Q.t
  operate_on_list(:ne, 18)

  @doc """
  Test if one value is less than the other.

      iex> lt(2,1) |> run conn
      %RethinkDB.Record{data: false}

      iex> lt(1, 2) |> run conn
      %RethinkDB.Record{data: true}
  """
  @spec lt(Q.reql_datum, Q.reql_datum) :: Q.t
  operate_on_two_args(:lt, 19)
  @doc """
  Test if all values in a list are less than the next. Left associative.

      iex> lt([1, 4, 2]) |> run conn
      %RethinkDB.Record{data: false}

      iex> lt([1, 4, 5]) |> run conn
      %RethinkDB.Record{data: true}
  """
  @spec lt([Q.reql_datum]) :: Q.t
  operate_on_list(:lt, 19)

  @doc """
  Test if one value is less than or equal to the other.

      iex> le(1,1) |> run conn
      %RethinkDB.Record{data: true}

      iex> le(1, 2) |> run conn
      %RethinkDB.Record{data: true}
  """
  @spec le(Q.reql_datum, Q.reql_datum) :: Q.t
  operate_on_two_args(:le, 20)
  @doc """
  Test if all values in a list are less than or equal to the next. Left associative.

      iex> le([1, 4, 2]) |> run conn
      %RethinkDB.Record{data: false}

      iex> le([1, 4, 4]) |> run conn
      %RethinkDB.Record{data: true}
  """
  @spec le([Q.reql_datum]) :: Q.t
  operate_on_list(:le, 20)

  @doc """
  Test if one value is greater than the other.

      iex> gt(1,2) |> run conn
      %RethinkDB.Record{data: false}

      iex> gt(2,1) |> run conn
      %RethinkDB.Record{data: true}
  """
  @spec gt(Q.reql_datum, Q.reql_datum) :: Q.t
  operate_on_two_args(:gt, 21)
  @doc """
  Test if all values in a list are greater than the next. Left associative.

      iex> gt([1, 4, 2]) |> run conn
      %RethinkDB.Record{data: false}

      iex> gt([10, 4, 2]) |> run conn
      %RethinkDB.Record{data: true}
  """
  @spec gt([Q.reql_datum]) :: Q.t
  operate_on_list(:gt, 21)

  @doc """
  Test if one value is greater than or equal to the other.

      iex> ge(1,1) |> run conn
      %RethinkDB.Record{data: true}

      iex> ge(2, 1) |> run conn
      %RethinkDB.Record{data: true}
  """
  @spec ge(Q.reql_datum, Q.reql_datum) :: Q.t
  operate_on_two_args(:ge, 22)
  @doc """
  Test if all values in a list are greater than or equal to the next. Left associative.

      iex> le([1, 4, 2]) |> run conn
      %RethinkDB.Record{data: false}

      iex> le([10, 4, 4]) |> run conn
      %RethinkDB.Record{data: true}
  """
  @spec ge([Q.reql_datum]) :: Q.t
  operate_on_list(:ge, 22)

  @doc """
  Compute the logical inverse (not) of an expression.

      iex> not(true) |> run conn
      %RethinkDB.Record{data: false}

  """
  @spec not_r(Q.reql_bool) :: Q.t
  operate_on_single_arg(:not_r, 23)

  @doc """
  Generate a random float between 0 and 1.

      iex> random |> run conn
      %RethinkDB.Record{data: 0.43}

  """
  @spec random :: Q.t
  def random, do: %Q{query: [151, []]}
  @doc """
  Generate a random value in the range [0,upper). If upper is an integer then the
  random value will be an interger. If upper is a float it will be a float.

      iex> random(5) |> run conn
      %RethinkDB.Record{data: 3}

      iex> random(5.0) |> run conn
      %RethinkDB.Record{data: 3.7}

  """
  @spec random(Q.reql_number) :: Q.t
  def random(upper) when is_integer(upper), do: %Q{query: [151, [upper]]}
  def random(upper) when is_float(upper), do: %Q{query: [151, [upper], %{float: true}]}
  @doc """
  Generate a random value in the range [lower,upper). If either arg is an integer then the
  random value will be an interger. If one of them is a float it will be a float.

      iex> random(5, 10) |> run conn
      %RethinkDB.Record{data: 8}

      iex> random(5.0, 15.0,) |> run conn
      %RethinkDB.Record{data: 8.34}

  """
  @spec random(Q.reql_number, Q.reql_number) :: Q.t
  def random(lower, upper) when is_integer(lower) and is_integer(upper) do
    %Q{query: [151, [lower, upper]]}
  end
  def random(lower, upper) when is_float(lower) or is_float(upper) do
    %Q{query: [151, [lower, upper], %{float: true}]}
  end

  """
  Selection Queries
  """

  @doc """
  Reference a database.
  """
  @spec db(Q.reql_string) :: Q.t
  operate_on_single_arg(:db, 14)

  @doc """
  Return all documents in a table. Other commands may be chained after table to 
  return a subset of documents (such as get and filter) or perform further 
  processing.

  There are two optional arguments.

  * useOutdated: if true, this allows potentially out-of-date data to be returned, 
    with potentially faster reads. It also allows you to perform reads from a 
    secondary replica if a primary has failed. Default false.
  * identifierFormat: possible values are name and uuid, with a default of name. If 
    set to uuid, then system tables will refer to servers, databases and tables by 
    UUID rather than name. (This only has an effect when used with system tables.)
  """
  @spec table(Q.reql_string, Q.reql_opts) :: Q.t
  @spec table(Q.t, Q.reql_string, Q.reql_opts) :: Q.t
  operate_on_single_arg(:table, 15)
  operate_on_two_args(:table, 15)

  @doc """
  Get a document by primary key.

  If no document exists with that primary key, get will return nil.
  """
  @spec get(Q.t, Q.reql_datum) :: Q.t
  operate_on_two_args(:get, 16)

  @doc """
  Get all documents where the given value matches the value of the requested index.
  """
  @spec get_all(Q.t, Q.reql_array) :: Q.t
  operate_on_seq_and_list(:get_all, 78)
  
  """
  String Manipulation Queries
  """

  @doc """
  Checks a string for matches. 

  Example:

      iex> "hello world" |> match("hello") |> run conn
      iex> "hello world" |> match(~r(hello)) |> run conn

  """
  @spec match( (Q.reql_string), (Regex.t|Q.reql_string) ) :: Q.t
  def match(string, regex = %Regex{}), do: match(string, Regex.source(regex))
  def match(string, match_string), do: %Q{query: [97, [string, match_string]]}

  @doc """
  Split a `string` on whitespace.

      iex> "abracadabra" |> split |> run conn
      %RethinkDB.Record{data: ["abracadabra"]}
  """
  @spec split(Q.reql_string) :: Q.t
  def split(string), do: %Q{query: [149, [string]]}

  @doc """
  Split a `string` on `separator`.

      iex> "abra-cadabra" |> split("-") |> run conn
      %RethinkDB.Record{data: ["abra", "cadabra"]}
  """
  @spec split(Q.reql_string, Q.reql_string) :: Q.t
  def split(string, separator), do: %Q{query: [149, [string, separator]]}

  @doc """
  Split a `string` with a given `separator` into `max_result` segments.
  
      iex> "a-bra-ca-da-bra" |> split("-", 2) |> run conn
      %RethinkDB.Record{data: ["a", "bra", "ca-da-bra"]}
  
  """
  @spec split(Q.reql_string, (Q.reql_string|nil), integer) :: Q.t
  def split(string, separator, max_results), do: %Q{query: [149, [string, separator, max_results]]}

  @doc """
  Convert a string to all upper case.

      iex> "hi" |> upcase |> run conn
      %RethinkDB.Record{data: "HI"}

  """
  @spec upcase(Q.reql_string) :: Q.t
  def upcase(string), do: %Q{query: [141, [string]]}

  @doc """
  Convert a string to all down case.

      iex> "Hi" |> downcase |> run conn
      %RethinkDB.Record{data: "hi"}

  """
  @spec downcase(Q.reql_string) :: Q.t
  def downcase(string), do: %Q{query: [142, [string]]}

  """
  Table Functions
  """

  @doc """
  Create a table. A RethinkDB table is a collection of JSON documents.

  If successful, the command returns an object with two fields:

  * tables_created: always 1.
  * config_changes: a list containing one two-field object, old_val and new_val:
    * old_val: always nil.
    * new_val: the table’s new config value.

  If a table with the same name already exists, the command throws 
  RqlRuntimeError.

  Note: Only alphanumeric characters and underscores are valid for the table name.

  When creating a table you can specify the following options:

  * primary_key: the name of the primary key. The default primary key is id.
  * durability: if set to soft, writes will be acknowledged by the server 
    immediately and flushed to disk in the background. The default is hard: 
    acknowledgment of writes happens after data has been written to disk.
  * shards: the number of shards, an integer from 1-32. Defaults to 1.
  * replicas: either an integer or a mapping object. Defaults to 1.
    If replicas is an integer, it specifies the number of replicas per shard. 
    Specifying more replicas than there are servers will return an error.
    If replicas is an object, it specifies key-value pairs of server tags and the 
    number of replicas to assign to those servers: {:tag1 => 2, :tag2 => 4, :tag3 
    => 2, ...}.
  * primary_replica_tag: the primary server specified by its server tag. Required 
    if replicas is an object; the tag must be in the object. This must not be 
    specified if replicas is an integer.
    The data type of a primary key is usually a string (like a UUID) or a number, 
    but it can also be a time, binary object, boolean or an array. It cannot be an 
    object.
  """
  @spec table_create(Q.t, Q.reql_string, Q.reql_opts) :: Q.t
  operate_on_single_arg(:table_create, 60)
  def table_create(name, opt) when is_map(opt), do: %Q{query: [60, [wrap(name)], opt]}
  operate_on_two_args(:table_create, 60)
  def table_create(db, name, opt) when is_map(opt), do: %Q{query: [60, [wrap(db), wrap(name)], opt]}

  @doc """
  Drop a table. The table and all its data will be deleted.

  If successful, the command returns an object with two fields:

  * tables_dropped: always 1.
  * config_changes: a list containing one two-field object, old_val and new_val:
    * old_val: the dropped table’s config value.
    * new_val: always nil.

  If the given table does not exist in the database, the command throws RqlRuntimeError.
  """
  @spec table_drop(Q.t, Q.reql_string) :: Q.t
  operate_on_single_arg(:table_drop, 61)
  operate_on_two_args(:table_drop, 61)

  @doc """
  List all table names in a database. The result is a list of strings.
  """
  @spec table_list(Q.t) :: Q.t
  operate_on_zero_args(:table_list, 62)
  operate_on_single_arg(:table_list, 62)

  @doc """
  Create a new secondary index on a table. Secondary indexes improve the speed of 
  many read queries at the slight cost of increased storage space and decreased 
  write performance. For more information about secondary indexes, read the 
  article “Using secondary indexes in RethinkDB.”

  RethinkDB supports different types of secondary indexes:

  * Simple indexes based on the value of a single field.
  * Compound indexes based on multiple fields.
  * Multi indexes based on arrays of values.
  * Geospatial indexes based on indexes of geometry objects, created when the geo 
    optional argument is true.
  * Indexes based on arbitrary expressions.

  The index_function can be an anonymous function or a binary representation 
  obtained from the function field of index_status.

  If successful, create_index will return an object of the form {:created => 1}. 
  If an index by that name already exists on the table, a RqlRuntimeError will be 
  thrown.
  """
  @spec index_create(Q.t, Q.reql_string, Q.reql_func1, Q.reql_opts) :: Q.t
  operate_on_two_args(:index_create, 75)
  operate_on_three_args(:index_create, 75)

  @doc """
  Delete a previously created secondary index of this table.
  """
  @spec index_drop(Q.t, Q.reql_string) :: Q.t
  operate_on_two_args(:index_drop, 76)

  @doc """
  List all the secondary indexes of this table.
  """
  @spec index_list(Q.t) :: Q.t
  operate_on_single_arg(:index_list, 77)

  @doc """
  Rename an existing secondary index on a table. If the optional argument 
  overwrite is specified as true, a previously existing index with the new name 
  will be deleted and the index will be renamed. If overwrite is false (the 
  default) an error will be raised if the new index name already exists.

  The return value on success will be an object of the format {:renamed => 1}, or 
  {:renamed => 0} if the old and new names are the same.

  An error will be raised if the old index name does not exist, if the new index 
  name is already in use and overwrite is false, or if either the old or new 
  index name are the same as the primary key field name.
  """
  @spec index_rename(Q.t, Q.reql_string, Q.reql_string, Q.reql_opts) :: Q.t
  operate_on_three_args(:index_rename, 156)

  @doc """
  Get the status of the specified indexes on this table, or the status of all 
  indexes on this table if no indexes are specified.
  """
  @spec index_status(Q.t, Q.reql_string|Q.reql_array) :: Q.t
  operate_on_single_arg(:index_status, 139)
  def index_status(table, indexes) when is_list(indexes) do
    %Q{query: [139, [wrap(table) | Enum.map(indexes, &wrap/1)]]}
  end

  @doc """
  Wait for the specified indexes on this table to be ready, or for all indexes on 
  this table to be ready if no indexes are specified.
  """
  @spec index_wait(Q.t, Q.reql_string|Q.reql_array) :: Q.t
  operate_on_single_arg(:index_wait, 140)
  def index_wait(table, indexes) when is_list(indexes) do
    %Q{query: [140, [wrap(table) | Enum.map(indexes, &wrap/1)]]}
  end

  """
  Writing Data Queries
  """

  @doc """
  Insert documents into a table. Accepts a single document or an array of 
  documents.

  The optional arguments are:

  * durability: possible values are hard and soft. This option will override the 
    table or query’s durability setting (set in run). In soft durability mode 
    Rethink_dB will acknowledge the write immediately after receiving and caching 
    it, but before the write has been committed to disk.
  * return_changes: if set to True, return a changes array consisting of 
    old_val/new_val objects describing the changes made.
  * conflict: Determine handling of inserting documents with the same primary key 
    as existing entries. Possible values are "error", "replace" or "update".
    * "error": Do not insert the new document and record the conflict as an error. 
      This is the default.
    * "replace": Replace the old document in its entirety with the new one.
    * "update": Update fields of the old document with fields from the new one.

  Insert returns an object that contains the following attributes:

  * inserted: the number of documents successfully inserted.
  * replaced: the number of documents updated when conflict is set to "replace" or 
    "update".
  * unchanged: the number of documents whose fields are identical to existing 
    documents with the same primary key when conflict is set to "replace" or 
    "update".
  * errors: the number of errors encountered while performing the insert.
  * first_error: If errors were encountered, contains the text of the first error.
  * deleted and skipped: 0 for an insert operation.
  * generated_keys: a list of generated primary keys for inserted documents whose 
    primary keys were not specified (capped to 100,000).
  * warnings: if the field generated_keys is truncated, you will get the warning 
    “Too many generated keys (<X>), array truncated to 100000.”.
  * changes: if return_changes is set to True, this will be an array of objects, 
    one for each objected affected by the insert operation. Each object will have 
  * two keys: {"new_val": <new value>, "old_val": None}.
  """
  @spec insert(Q.t, Q.reql_obj | Q.reql_array, %{}) :: Q.t
  operate_on_two_args(:insert, 56)

  @doc """
  Update JSON documents in a table. Accepts a JSON document, a ReQL expression, 
  or a combination of the two.

  The optional arguments are:

  * durability: possible values are hard and soft. This option will override the 
    table or query’s durability setting (set in run). In soft durability mode 
    RethinkDB will acknowledge the write immediately after receiving it, but before 
    the write has been committed to disk.
  * return_changes: if set to True, return a changes array consisting of 
    old_val/new_val objects describing the changes made.
  * non_atomic: if set to True, executes the update and distributes the result to 
    replicas in a non-atomic fashion. This flag is required to perform 
    non-deterministic updates, such as those that require reading data from another 
    table.

  Update returns an object that contains the following attributes:

  * replaced: the number of documents that were updated.
  * unchanged: the number of documents that would have been modified except the new 
    value was the same as the old value.
  * skipped: the number of documents that were skipped because the document didn’t 
    exist.
  * errors: the number of errors encountered while performing the update.
  * first_error: If errors were encountered, contains the text of the first error.
  * deleted and inserted: 0 for an update operation.
  * changes: if return_changes is set to True, this will be an array of objects, 
    one for each objected affected by the update operation. Each object will have 
  * two keys: {"new_val": <new value>, "old_val": <old value>}.
  """
  @spec update(Q.t, Q.reql_obj, %{}) :: Q.t
  operate_on_two_args(:update, 53)

  @doc """
  Replace documents in a table. Accepts a JSON document or a ReQL expression, and 
  replaces the original document with the new one. The new document must have the 
  same primary key as the original document.

  The optional arguments are:

  * durability: possible values are hard and soft. This option will override the 
    table or query’s durability setting (set in run).
    In soft durability mode RethinkDB will acknowledge the write immediately after 
    receiving it, but before the write has been committed to disk.
  * return_changes: if set to True, return a changes array consisting of 
    old_val/new_val objects describing the changes made.
  * non_atomic: if set to True, executes the replacement and distributes the result 
    to replicas in a non-atomic fashion. This flag is required to perform 
    non-deterministic updates, such as those that require reading data from another 
    table.

  Replace returns an object that contains the following attributes:

  * replaced: the number of documents that were replaced
  * unchanged: the number of documents that would have been modified, except that 
    the new value was the same as the old value
  * inserted: the number of new documents added. You can have new documents 
    inserted if you do a point-replace on a key that isn’t in the table or you do a 
    replace on a selection and one of the documents you are replacing has been 
    deleted
  * deleted: the number of deleted documents when doing a replace with None
  * errors: the number of errors encountered while performing the replace.
  * first_error: If errors were encountered, contains the text of the first error.
  * skipped: 0 for a replace operation
  * changes: if return_changes is set to True, this will be an array of objects, 
    one for each objected affected by the replace operation. Each object will have 
  * two keys: {"new_val": <new value>, "old_val": <old value>}.
  """
  @spec replace(Q.t, Q.reql_obj, %{}) :: Q.t
  operate_on_two_args(:replace, 55)

  @doc """
  Delete one or more documents from a table.

  The optional arguments are:

  * durability: possible values are hard and soft. This option will override the 
    table or query’s durability setting (set in run).
    In soft durability mode RethinkDB will acknowledge the write immediately after 
    receiving it, but before the write has been committed to disk.
  * return_changes: if set to True, return a changes array consisting of 
    old_val/new_val objects describing the changes made.

  Delete returns an object that contains the following attributes:

  * deleted: the number of documents that were deleted.
  * skipped: the number of documents that were skipped.
    For example, if you attempt to delete a batch of documents, and another 
    concurrent query deletes some of those documents first, they will be counted as 
    skipped.
  * errors: the number of errors encountered while performing the delete.
  * first_error: If errors were encountered, contains the text of the first error.
    inserted, replaced, and unchanged: all 0 for a delete operation.
  * changes: if return_changes is set to True, this will be an array of objects, 
    one for each objected affected by the delete operation. Each object will have 
  * two keys: {"new_val": None, "old_val": <old value>}.
  """
  @spec delete(Q.t) :: Q.t
  operate_on_single_arg(:delete, 54)

  @doc """
  sync ensures that writes on a given table are written to permanent storage. 
  Queries that specify soft durability (durability='soft') do not give such 
  guarantees, so sync can be used to ensure the state of these queries. A call to 
  sync does not return until all previous writes to the table are persisted.

  If successful, the operation returns an object: {"synced": 1}.

  """
  @spec sync(Q.t) :: Q.t
  operate_on_single_arg(:sync, 138)

  """
  Date and Time Queries
  """

  @doc """
  Return a time object representing the current time in UTC. The command now() is 
  computed once when the server receives the query, so multiple instances of 
  r.now() will always return the same time inside a query.
  """
  @spec now() :: Q.t
  operate_on_zero_args(:now, 103)

  @doc """
  """
  @spec time(reql_number, reql_number, reql_number, reql_string) :: Q.t
  def time(year, month, day, timezone), do: %Q{query: [136, [year, month, day, timezone]]}
  @spec time(reql_number, reql_number, reql_number, reql_number, reql_number, reql_number, reql_string) :: Q.t
  def time(year, month, day, hour, minute, second, timezone) do
    %Q{query: [136, [year, month, day, hour, minute, second, timezone]]}
  end

  """
  Transformations Queries
  """

  @doc """
  Transform each element of one or more sequences by applying a mapping function 
  to them. If map is run with two or more sequences, it will iterate for as many 
  items as there are in the shortest sequence.

  Note that map can only be applied to sequences, not single values. If you wish 
  to apply a function to a single value/selection (including an array), use the 
  do command.
  """
  @spec map(Q.reql_array, Q.reql_func1) :: Q.t
  operate_on_two_args(:map, 38)

  def flat_map(sequence, f), do: %Q{query: [40, [sequence, func(f)]]}
  def concat_map(sequence, f), do: flat_map(sequence, f)

  
  def make_array(array), do:  %Q{query: [2, array]}

  def filter(query, f) when is_list(query), do: filter(make_array(query), f)
  def filter(query, f) when is_function(f), do: %Q{query: [39, [query, func(f)]]}
  def filter(query, filter), do: %Q{query: [39, [query, filter]]}

  def between(query, lower, upper, options \\ %{}), do: [182, [query, lower, upper, options]]

  def changes(selection), do: %Q{query: [152, [selection]]}

  def get_field(seq, field) when is_list(seq), do: get_field(make_array(seq), field)
  def get_field(seq, field), do: %Q{query: [31, [seq, field]]}
  def keys(object), do: %Q{query: [94, [object]]}

  def pluck(seq, f) when is_list(seq), do: pluck(make_array(seq), f)
  def pluck(selection, fields) when is_list(fields), do: %Q{query: [33, [selection | fields]]}
  def pluck(selection, field), do: %Q{query: [33, [selection, field]]}
  def without(selection, fields), do: %Q{query: [34, [selection | fields]]}
  def has_fields(sequence, fields), do:  %Q{query: [32, [sequence, make_array(fields)]]}

  def merge(objects), do: %Q{query: [35, objects]}

  def order_by(sequence, order), do: order_by(sequence, order, %{})
  def order_by(sequence, order, options) when is_list(order), do: %Q{query: [41, [sequence | order], options]}
  def order_by(sequence, order, options), do: %Q{query: [41, [sequence, order], options]}

  def append(array, datum), do: %Q{query: [29, [array, datum]]}
  def prepend(array, datum), do: %Q{query: [30, [array, datum]]}
  def difference(arrayA, arrayB), do: %Q{query: [95, [arrayA, arrayB]]}

  def slice(seq, start, end_el) when is_list(seq), do: slice(make_array(seq), start, end_el)
  def slice(seq, start, end_el), do: %Q{query: [30, [seq, start, end_el]]}
  def skip(seq, count) when is_list(seq), do: skip(make_array(seq), count)
  def skip(seq, count), do: %Q{query: [70, [seq, count]]}
  def limit(seq, count) when is_list(seq), do: limit(make_array(seq), count)
  def limit(seq, count), do: %Q{query: [71, [seq, count]]}
  def offsets_of(seq, el) when is_list(seq), do: offsets_of(make_array(seq), el)
  def offsets_of(seq, f) when is_function(f), do: %Q{query: [87, [seq, func(f)]]}
  def offsets_of(seq, el), do: %Q{query: [87, [seq, el]]}
  def asc(key), do: %Q{query: [73, [key]]}
  def desc(key), do: %Q{query: [74, [key]]}

  def func(f) when is_function(f) do
    {_, arity} = :erlang.fun_info(f, :arity)

    args = case arity do
      0 -> []
      _ -> Enum.map(1..arity, fn _ -> make_ref end)
    end
    params = Enum.map(args, &var/1)

    res = case apply(f, params) do
      x when is_list(x) -> make_array(x)
      x -> x
    end
    %Q{query: [69, [[2, args], res]]}
  end

  def var(val), do: %Q{query: [10, [val]]}
  def bracket(obj, key), do: %Q{query: [170, [obj, key]]}

end

