import unittest, hts/vcf, hts_sugar

suite "vcf suite":

  test "write vcf from scratch":

    #test write header
    var h:Header
    init_header(h, samples = @["mysample", "mysample2"])
    check h.add_contig("1",(species:"Human")) == Status.OK
    check h.add_filter("FLAG1", "Dummy") == Status.OK
    check h.add_info("DP", "1", "Integer", "total reads covering this site") == Status.OK
    check h.add_format("Test", "1", "String", "random string") == Status.OK

    var v:VCF

    if not open(v, "tests/test.vcf.gz", mode="w"):
        quit "could not open vcf"

    v.header = h
    check v.samples == @["mysample", "mysample2"]
    check v.write_header()

    #test create variant
    var vr : Variant
    vr = v.new_variant("1", 1, id="test_id", REF="G", ALT="T", filters = @["FLAG1"], qual = 60)
    var val = 35
    check vr.info.set("DP", val) == Status.OK
    var val2 = @[".","test"]
    check vr.format.set("Test", val2) == Status.OK
    check v.write_variant(vr)

    v.close()
