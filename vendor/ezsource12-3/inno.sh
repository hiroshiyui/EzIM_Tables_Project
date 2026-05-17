#!/bin/bash
wine bin/inno/iscc.exe doc/tts/tts.iss /Ooutput/tts
wine bin/inno/iscc.exe doc/tts/ttssmall.iss /Ooutput/tts
wine bin/inno/iscc.exe doc/tts/ttsmid.iss /Ooutput/tts
wine bin/inno/iscc.exe doc/tts/ttsbig.iss /Ooutput/tts

