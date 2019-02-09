hts-nim-sugar
=============

This package provides some wrapper code around [hts-nim](https://github.com/brentp/hts-nim) to add ease of use functionality.

Currently adds functions to easily write new VCF files.

Example:

```nim
import hts/vcf
import hts-sugar

var h:Header

init_header(h, samples = @["mysample", "mysample2"])
doAssert h.add_contig("1") == Status.OK
doAssert h.add_contig("2",(species:"Human")) == Status.OK
doAssert h.add_filter("FLAG1", "Dummy") == Status.OK
doAssert h.add_filter("FLAG2", "Dummy") == Status.OK
doAssert h.add_info("DP", "1", "Integer", "total reads covering this site") == Status.OK
doAssert h.add_format("Test", "1", "String", "random string") == Status.OK

var ovcf:VCF

if not open(ovcf, "out.vcf", mode="w"):
  quit "could not open vcf"

ovcf.header = h
doAssert ovcf.write_header

var vr : Variant
vr = ovcf.new_variant("1", 100, REF="G", ALT="T", filters = @["FLAG2"], qual=60)
var val = 35
discard vr.info.set("DP", val)
var val2 = @[".","test"]
discard vr.format.set("Test", val2)
doAssert ovcf.write_variant(vr)

ovcf.close()
```
