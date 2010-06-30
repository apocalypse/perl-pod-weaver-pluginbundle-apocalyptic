package Pod::Weaver::PluginBundle::Apocalyptic;

# ABSTRACT: Let the apocalypse generate your POD!

use Pod::Weaver::Config::Assembler 3.100710;

# The plugins we use ( excluding ones bundled in podweaver )
use Pod::Weaver::Section::SeeAlso 0.001;
use Pod::Weaver::Section::Support 0.008;
use Pod::Elemental::Transformer::List 0.093580;

sub _exp {
	Pod::Weaver::Config::Assembler->expand_package( $_[0] );
}

sub mvp_bundle_config {
	return (
		# some basics we need
		[ '@Apocalyptic/CorePrep',	_exp('@CorePrep'), {} ],

		# Move our special markers to the start of the POD
		[ '@Apocalyptic/PodCoverage',	_exp('Region'), {
			region_name	=> 'Pod::Coverage',
			allow_nonpod	=> 1,
			flatten		=> 0,
		} ],
		[ '@Apocalyptic/PodSpelling',	_exp('Region'), {
			region_name	=> 'stopwords',
			allow_nonpod	=> 1,
			flatten		=> 0,
		} ],

		# Start the POD!
		[ '@Apocalyptic/Name',		_exp('Name'), {} ],
		[ '@Apocalyptic/Version',	_exp('Version'), {
			format		=> 'This document describes v%v of %m - released %{LLLL dd, yyyy}d as part of %r.',
			is_verbatim	=> 1,
		} ],

		# The standard sections
		[ '@Apocalyptic/Synopsis',	_exp('Generic'), {
			header		=> 'SYNOPSIS',
		} ],
		[ '@Apocalyptic/Description',	_exp('Generic'), {
			header		=> 'DESCRIPTION',
			required	=> 1,
		} ],

		# Our subs
		[ '@Apocalyptic/Attributes',	_exp('Collect'), {
			header		=> 'ATTRIBUTES',
			command		=> 'attr',
		} ],
		[ '@Apocalyptic/Methods',	_exp('Collect'), {
			header		=> 'METHODS',
			command		=> 'method',
		} ],
		[ '@Apocalyptic/Functions',	_exp('Collect'), {
			header		=> 'FUNCTIONS',
			command		=> 'func',
		} ],

		# Anything that wasn't matched gets dumped here
		[ '@Apocalyptic/Leftovers',	_exp('Leftovers'), {} ],

		# The usual end of POD...
		[ '@Apocalyptic/SeeAlso',	_exp('SeeAlso'), {} ],
		[ '@Apocalyptic/Support',	_exp('Support'), {} ],
		[ '@Apocalyptic/Authors',	_exp('Authors'), {} ],
		[ '@Apocalyptic/ACK',		_exp('Generic'), {
			header		=> 'ACKNOWLEDGEMENTS',
		} ],
		[ '@Apocalyptic/Legal',		_exp('Legal'), {
			filename	=> 'LICENSE',
		} ],

		# Mangle the entire POD
		[ '@Apocalyptic/ListTransformer',	_exp('-Transformer'), {
			transformer	=> 'List',
		} ],
	);
}

1;

=for Pod::Coverage mvp_bundle_config

=head1 DESCRIPTION

This plugin bundle formats your POD and adds some sections and sets some custom options. Naturally, in order for
most of the plugins to work, you need to use this in conjunction with L<Dist::Zilla>.

It is nearly equivalent to the following in your F<weaver.ini>:

	[@CorePrep]			; setup the pod stuff
	[Region / Pod::Coverage]	; move any Pod::Coverage markers to the top ( =for Pod::Coverage foo bar )
	[Region / Stopwords]		; move any Pod::Spell markers to the top ( =for stopwords foo bar )

	[Name]				; automatically generate the NAME section
	[Version]			; automatically generate the VERSION section
	format = This document describes v%v of %m - released %{LLLL dd, yyyy}d as part of %r.
	is_verbatim = 1

	[Generic / SYNOPSIS]		; move the SYNOPSIS section here, if it exists
	[Generic / DESCRIPTION]		; move the DESCRIPTION section here ( it is required to exist! )

	[Collect / ATTRIBUTES]		; get any POD marked as =attr and list them here
	command = attr
	[Collect / METHODS]		; get any POD marked as =method and list them here
	command = method
	[Collect / FUNCTIONS]		; get any POD marked as =func and list them here
	command = func

	[Leftovers]			; any other POD you use

	[SeeAlso]			; generate the SEE ALSO section via L<Pod::Weaver::Section::SeeAlso>
	[Support]			; generate the SUPPORT section via L<Pod::Weaver::Section::Support> ( only present in main module )
	[Authors]			; automatically generate the AUTHOR(S) section
	[Generic / ACKNOWLEDGEMENTS]	; move the ACKNOWLEDGEMENTS section here, if it exists
	[Legal]				; automatically generate the COPYRIGHT AND LICENSE section
	filename = LICENSE

	[-Transformer]			; mangle all :list pod into proper lists via L<Pod::Elemental::Transformer::List>
	transformer = List

=head1 Future Plans

=head2 auto image in POD?

=begin HTML
<p><img src="http://i.imgur.com/Hb2cD.png" width="600"></p>
=end HTML

Saw that in http://search.cpan.org/~wonko/Smolder-1.51/lib/Smolder.pm

Maybe we can make a transformer to automatically do that? ( =image http://blah.com/foo.png )

<jhannah> Apocalypse: ya, right? cool and dangerous and prone to FAIL as URLs become invalid... :/
<jhannah> I'd hate to see craptons of broken images on s.c.o   :(
<Apocalypse> Yeah jhannah it would be best if you could include the image in the dist itself... but that's a problem for another day :)
<jhannah> Apocalypse: it'd be trivial to include the .jpg in the .tgz... but what's the POD markup for that? and would s.c.o. do it correctly?
<jhannah> =begin HTML is ... eep
<Apocalypse> I think you could do it via sneaky means but it's prone to breakage
<Apocalypse> i.e. include it in dist as My-Foo-Dist/misc/image.png and link to it via s.c.o's "browse dist" directory
<Apocalypse> i.e. link to http://cpansearch.perl.org/src/WONKO/Smolder-1.51/misc/image.png
<Apocalypse> I should try that sneaky tactic and see if it works =]

=cut
