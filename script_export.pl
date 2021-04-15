#!/usr/bin/perl
use strict;
use warnings;
# for filepath computing
use File::Basename;
# to decode HTML entities (mandatory for highlighting, see below)
use HTML::Entities;
# to communicate both read and write with source-highlighting
use IPC::Open3;	 

# useful files and directories
my $DIR_SOURCE = "./source";
my $DIR_EXPORT = "./export";
my $FILE_TOP_HTML = "$DIR_SOURCE/top.html";
my $FILE_BOT_HTML = "$DIR_SOURCE/bot.html";
my $DIR_SOURCE_DATA = "$DIR_SOURCE/data";
my $DIR_EXPORT_DATA = "$DIR_EXPORT/data";

# some checks on source dirs
checkfile("edr",$DIR_SOURCE);
checkfile("efr",$FILE_TOP_HTML);
checkfile("efr",$FILE_BOT_HTML);
checkfile("edr",$DIR_SOURCE_DATA);

# create export dir if not existing
system ("mkdir -vp $DIR_EXPORT");
checkfile("edw",$DIR_EXPORT);

# delete symlink if existing and create new one
if (-e $DIR_EXPORT_DATA) { system("unlink $DIR_EXPORT_DATA"); }
system ("ln -vs ../$DIR_SOURCE_DATA $DIR_EXPORT_DATA");
checkfile("elw",$DIR_EXPORT_DATA);

# get the markdown pages filepaths
my @all_md_filepaths = split (/\n/, `ls -1 $DIR_SOURCE/*.md`);

# export each markdown to html export file
foreach my $md_filepath (@all_md_filepaths) {
	$md_filepath =~ s/\s//g ;
	checkfile("er",$md_filepath);
	
	# convert md to html
	my $html_content = `cmark --unsafe --to html $md_filepath` ;
	
	# highlighting code nodes
	$html_content =~ 
	s/<pre><code class="([\w-]*)">([\s\S]*?)<\/code><\/pre>/replace($1,$2)/ge ;
	
	# preparing top content
	my ($title) = $html_content =~ m/<h1>(.*?)<\/h1>/ ;
	my $top_html = `cat $FILE_TOP_HTML` ;
	$top_html =~ s/<title><\/title>/"<title>$title<\/title>"/e ;
	
	# computing filepath
	my $html_basename = basename($md_filepath);
	$html_basename =~ s/\.md$/\.html/;
	my $html_filepath = "$DIR_EXPORT/$html_basename" ;
	
	# write to filepath
	open (my $fd_html, '>', $html_filepath)
	or die ("Cannot open $html_filepath");
	print $fd_html ($top_html, $html_content);
	close($fd_html);
	
	# adding bot content
	system("cat $FILE_BOT_HTML >> $html_filepath");
	
	print ("Parsed $md_filepath -> $html_filepath\n") ;
}

# function to replace code node with highlighted code node
sub replace { 
	my ($language_name,$content) = @_ ;
	
	# extract name of language
	my $name = $language_name ;
	$name =~ s/language-// ;

	# decode HTML entities, because cmark already encode them
	# source-highlight is not going to treat '&amp;' as '&'
	decode_entities($content);
	
	# open command source-highlight
	my $cmd = "source-highlight -s $name -f html-css --failsafe" ;
	open3(my $fdw_cmd, my $fdr_cmd, ">&STDERR", $cmd)
	or die("Could not call source-highlight correctly");

	# print content to command
	print $fdw_cmd ($content);
	close($fdw_cmd);
		
	# read result content from command
	my $code = do { local $/ = undef ; <$fdr_cmd>; };
	close($fdr_cmd);
	
	# replacing bad html wrapper with correct html5 one
	$code =~ s/<tt>/"<code class=\"$language_name\" >"/e ;
	$code =~ s/<\/tt>/<\/code>/ ;
	
	return $code;
}

# function to check files
sub checkfile { my ($checks, $filepath) = @_ ;
	if ($checks =~ m/d/) { 
		(-d $filepath) or die ("Path $filepath is not a directory"); }
	if ($checks =~ m/e/) { 
		(-e $filepath) or die ("Path $filepath does not exist"); }
	if ($checks =~ m/f/) { 
		(-f $filepath) or die ("Path $filepath is not a file"); }
	if ($checks =~ m/l/) { 
		(-l $filepath) or die ("Path $filepath is not a symbolic link"); }
	if ($checks =~ m/r/) {
		(-r $filepath) or die("Path $filepath can not be read"); }
	if ($checks =~ m/w/) {
		(-w $filepath) or die("Path $filepath can not be written"); }
}

