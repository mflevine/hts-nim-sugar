import hts/vcf
import hts/private/hts_concat
import strutils

proc init_header*(h: var Header, samples:seq[string] = @[]) =
  ## initialize an empty VCF header
  var default_header = ("""##fileformat=VCFv4.2
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT""")
  if len(samples) != 0:
    default_header &= "	" & samples.join("	")
  h.from_string(default_header)

proc add_contig*(h:Header, ID:string, meta:tuple = ()): Status =
  ## add a contig field to the header with the given values
  var str = "##contig=<ID=" & ID
  for key, value in fieldPairs(meta):
    str &= "," & key & "=" & value
  return h.add_string(str & ">")

proc add_filter*(h:Header, ID:string, Description: string): Status =
  ## add a FILTER field to the header with the given values
  return h.add_string(format("##FILTER=<ID=$#,Description=\"$#\">", ID, Description))


proc add_filters*(v:Variant, filters:seq[string]) =
  ## add filter flags to variant
  var filter_id: cint
  for filter in filters:
    filter_id = bcf_hdr_id2int(v.vcf.header.hdr, BCF_DT_ID, filter)
    doAssert bcf_add_filter(v.vcf.header.hdr, v.c, filter_id) == 1, "error adding filter"

proc new_variant*(v:VCF, contig: string, pos1: int32, id:string=".", REF:string=".", ALT:string=".", qual:float = 0, filters:seq[string] = @[]): Variant =
  ## create a new variant for VCF with the given values (base-1 position).
  result = newVariant()
  result.vcf = v
  result.c.rid = bcf_hdr_name2id(result.vcf.header.hdr, contig)
  result.c.pos = pos1 - 1
  result.c.d.id = id
  doAssert bcf_update_alleles_str(result.vcf.header.hdr, result.c, REF & "," & ALT) == 0, "error adding alleles"
  result.c.qual = qual
  result.add_filters(filters)
