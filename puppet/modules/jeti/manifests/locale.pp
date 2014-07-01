class jeti::locale ($locales)
{
    $default_locale = split($locales[0], ' ')

    class {'::locales':
        default_locale => $default_locale[0],
        locales        => $locales
    }
}
