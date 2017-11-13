
include Util

module Insert = Insert
module Select = Select
module Update = Update

let connect = Mdb.connect 
let close = Mdb.close

let or_die = Util.or_die