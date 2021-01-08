#!/usr/bin/perl
#
# Youngjae
# Usage : make_Libri2Mix.pl $dataset data

#if (@ARGV != 2) {
#    print STDERR "Usage: $0 <path-to-Libri2Mix> <data-dir>\n";
#    print STDERR "e.g. $0 dataset-dir data \n";
#    exit(1);
#}

# ($data_base, $out_dir) = @ARGV;
$data_base = "/home/old_data_20201222/datasets/LibriMix/Libri2Mix/wav16k";
$out_dir = "/home/dhodwo/E2E_SPEECH_SEP_RCG/script";

my $out_dir = "$out_dir/Libri2Mix/wav16k";

#max or min
opendir my $dh, "$data_base" or die "Cannot open directory: $!";
my @path1_dirs = grep {-d "$data_base/$_" && ! /^\.{1,2}$/} readdir($dh);
closedir $dh;

## print @path1_dirs; => min max
foreach (@path1_dirs){
    my $path1_dir = $_;

    #train or dev except metadata
    opendir my $dh, "$data_base/$path1_dir" or die "Cannot open directory: $!";
    ## print "$data_base/$path1_dir"; => home/~~~/min and max
    my @path2_dirs = grep {-d "$data_base/$path1_dir/$_" && ! /^\.{1,2}$/} readdir($dh);
    closedir $dh;
    ## print @path2_dirs; => train-100 metadata dev train-360 test

    #=pod
    foreach (@path2_dirs){
        my $path2_dir = $_;

        if ($path2_dir ne "metadata") {
            #mix_both and others (ex. s1, s2)
            opendir my $dh, "$data_base/$path1_dir/$path2_dir" or die "Cannot open directory: $!";
            my @path3_dirs = grep {-d "$data_base/$path1_dir/$path2_dir/$_" && ! /^\.{1,2}$/} readdir($dh);
            closedir $dh;
            ## print @path3_dirs; => mix_both mix_clean s1 mix_single noise s2

            foreach (@path3_dirs){
                my $path3_dir = $_;
                my $out_dir_sub = "$out_dir/$path1_dir/$path2_dir/$path3_dir";

                if (system("mkdir -p $out_dir_sub") !=0){
                    die "Error making directory $out_dir_sub";
                }

                open(SPKR, ">", "$out_dir_sub/utt2spk") or die "Could not open the output file $out_dir_sub/utt2spk";
                open(WAV, ">", "$out_dir_sub/wav.scp") or die "Could not open the output file $out_dir_sub/wav.scp";

                opendir my $dh, "$data_base/$path1_dir/$path2_dir/$path3_dir" or die "Cannot open directory: $!";
                my @files = map{s/\.[^.]+$//;$_}grep {/\.wav$/} readdir($dh);
                closedir $dh;

                foreach (@files) {
                    my $filename = $_;
                    my $wav = "$data_base/$path1_dir/$path2_dir/$path3_dir/$filename.wav";

                    print WAV "$filename", " $wav", "\n";
                    print SPKR "$filename", " $filename", "\n";
                }
                close(SPKR) or die;
                close(WAV) or die;
                
=pod
                if (system("utils/utt2spk_to_spk2utt.pl $out_dir_sub/utt2spk>$out_dir_sub/spk2utt") != 0){
                    die "Error creating spk2utt file in directory $out_dir_sub";
                }
                system("env LC_COLLATE=C utils/fix_data_dir.sh $out_dir_sub");
                if (system("env LC_COLLATE=C utils/validate_data_dir.sh --no-text --no-feats $out_dir_sub") != 0) {
                    die "Error validation directory $out_dir_sub";
                }
=cut

            }
        }
    }
    #=cut
}
