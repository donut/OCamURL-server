
include Util

module Insert = Insert
module Select = Select

let connect = Mdb.connect 
let close connection = Mdb.close connection

let or_die = Util.or_die