params.help = null
params.output_folder = "."
params.table_extension = "tsv"
params.thread = 1
params.annovar_db = "Annovar_db/"

if (params.help) {
    log.info ''
    log.info '--------------------------------------------------'
    log.info '                   TABLE ANNOVAR                  '
    log.info '--------------------------------------------------'
    log.info ''
    log.info 'Usage: '
    log.info 'nextflow run table_annovar.nf --table_folder myinputfolder'
    log.info ''
    log.info 'Mandatory arguments:'
    log.info '    --table_folder       FOLDER            Folder containing tables to process.'
    log.info 'Optional arguments:'
    log.info '    --output_folder	FOLDER		Folder where output is written.'
    log.info ''
    exit 1
}

tables = Channel.fromPath( params.table_folder+'/*.'+params.table_extension)
                 .ifEmpty { error "empty table folder, please verify your input." }

annodb = file( params.annovar_db )

process annovar {
  cpus params.thread
  memory '2GB'
  tag { file_name }

  input:
  file table from tables
  file annodb

  output:
  file "*multianno*" into output_annovar

  publishDir params.output_folder, mode: 'copy'

  shell:
  if(params.table_extension=="vcf"|params.table_extension=="vcf.gz"){
	vcf="--vcfinput -nastring ."
  }else{
	 vcf="-nastring NA "
  }
  file_name = table.baseName
  '''
  table_annovar.pl -buildver hg38 --thread !{params.thread} --onetranscript !{vcf} -remove -protocol refGene,exac03nontcga,esp6500siv2_all,1000g2015aug_all,gnomad_genome,gnomad_exome,clinvar_20170905,revel,ljb26_all -operation g,f,f,f,f,f,f,f,f -otherinfo !{table} !{annodb} -out !{file_name}
  '''
}
