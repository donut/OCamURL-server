
module Convertable = Convertable
module Ext_list = Ext_list
module Ext_option = Ext_option

let ( <% ) l r x = x |> r |> l
let ( %> ) l r x = x |> l |> r

let flip f a b = f b a
let id x = x