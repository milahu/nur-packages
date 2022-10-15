{ lib
, newScope
}:

lib.makeScope newScope (self: with self; {

  udd = callPackage ./udd {};

})
