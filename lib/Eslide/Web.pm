use MooseX::Declare;

my $template = q{
<html>
<head>
<title>Eslide</title>
</head>
<body style="font-size: 30pt">
<a href="/prev">Prev</a>
<a href="/next">Next</a>
<hr />
[% current | html_para %]
</body>
</html>
};

class Eslide::Web with (MooseX::Runnable, HTTP::Engine::Role) {
    use feature 'switch';
    use String::TT qw(tt);
    method handle_request($req){
        my $url = $req->path;

        given($url){
            when(/next/){
                `emacsclient --eval '(eslide-next)'`;
            }
            when(/prev/){
                `emacsclient --eval '(eslide-prev)'`;
            }
        }

        my $current = `emacsclient --eval '(with-current-buffer "*ESlide Notes*" (buffer-substring-no-properties (point-min) (point-max)))'`;

        $current =~ s/^"//g;
        $current =~ s/"$//g;
        $current =~ s/\\n/\n/g;
        $current =~ s/\\(.)/$1/g;

        my $response = HTTP::Engine::Response->new(
            content_type => 'text/html; charset=utf8',
            body         => tt($template),
        );
    }

    method run() {
        $self->engine->run;
        return 0;
    }
}

__END__

