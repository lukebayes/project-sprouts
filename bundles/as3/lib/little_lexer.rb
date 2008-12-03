
# Little Lexer, a very small very simple lexical scanner and parser class
#
# I wrote this in the middle of the night because the idea was sooo cute.
#
#     Copyright (C) 2004  John Carter
     
#     This library is free software; you can redistribute it and/or modify it
#     under the terms of the GNU Lesser General Public License as published by
#     the Free Software Foundation; either version 2.1 of the License, or (at
#     your option) any later version.
     
#     This library is distributed in the hope that it will be useful, but
#     WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     Lesser General Public License for more details.
     
#     You should have received a copy of the GNU Lesser General Public
#     License along with this library; if not, write to the Free Software
#     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
#     USA.

class LexerJammed < Exception
end

# A tiny very very simple Lexer/Parser class.
#
# Feed it an array of [regex,char] pairs and it
# scans an input string returning a string of char's matching 
# the tokens found.

# What makes this such a very very very cute idea (apart from the fact
# it so very small) is...  Traditionally Lexical scanners such as flex
# yield a stream of tokens id's (usully an int or an enum) and the
# token (usually a string). I have chosen (this is the smart bit) to
# make each token id a character (which limits the number of possible
# token id's a bit, but certainly not for any practical use), and not
# return a stream of token id's and tokens, but an array.

# Now an array of token id's is just an array of char which is just a
# string!

# WAKE UP! This is VERY cute! Thus the output of the lexical scanner
# is just a string which can be used as the input to a lexical scanner.

# Thus we can use the very same class as both a lexical scanner _AND_
# a parser!

# I _told_ you it was cute.

# See the tests for examples.
#
class Lexer

  # Constructs a Lexer that can be used and reused
  # to scan a string for tokens.
  #
  #  Parameters
  #   regex_to_char is an enumeration of [regex,char] pairs.
  #                 The 'next_token' method tries to match each 
  #                 regex in order, if one matches, the matching 
  #                 token and corresponding char is returned.
  #   skip_white_space - If true, token that corresponds to ?\s (space)
  #                 will be skipped.
  # 
  def initialize(regex_to_char,skip_white_space = true)
    @skip_white_space = skip_white_space
    @regex_to_char = regex_to_char
  end

  # Scans a string for tokens
  #
  # Parameters
  #   string - String to scan for tokens
  #   string_token_list - token list output by first pass.
  #
  # Returns a string of token id's and a token list.
  #
  # If string_token_list is nil, (the default) then...
  #   The input string is scanned and broken up into tokens as
  #   follows.  Each regex in the regex to char list is tried in order
  #   until either one matches, in which case the corresponding token
  #   id char is appended to the output string, and the token is
  #   appended to the token list.  The token is removed from the front
  #   of the string and the it then tries again until all tokens have
  #   been found or no regex matches.  If no regex in the regex to
  #   char list matches, then the Lexer jam's and throws a LexerJammed
  #   exception

  # If the input string is the output string of a another Lexer
  # instance's scan and the string_token_list is the matching token
  # list, then the output token list is a list of pairs. The first
  # element in each pair is a subarray of the string_token_list that
  # matches the token matched. The token matched is in the second
  # element of the pair. Thus a parser can work make to the original
  # token's found by the lexer.

  def scan(string,string_token_list=nil)
    result_string  = ''
    token_list = []
    
    if string_token_list
      next_token(string) do |t,token, tail|
        result_string << t
        token_list << [string_token_list[0...tail], string[0...tail]]
        string = string[tail..-1]
        string_token_list = string_token_list[tail..-1]
      end
    else
      next_token(string) do |t,token, tail|
        result_string << t
        token_list << token
        yield t, token if block_given?
      end
    end
    return result_string, token_list
  end

  private

  # Private method for scan that finds the next token.
  #
  # Parameters 
  #   string - input string to be scanned.
  #   block - yield's the token id char, token and offset of the end of the token.
  #
  # Throws LexerJammed if fails, details holds string it failed on.
  #
  # Returns void
  def next_token( string)
    match_data = nil
    while string != ''
      failed = true
      @regex_to_char.each do |regex,char|
        match_data = regex.match(string)
        next unless match_data
        token = match_data[0]
        yield char,token, match_data.end(0) unless char == ?\s && @skip_white_space 
        string = match_data.post_match
        failed = false
        break
      end
      raise LexerJammed, string if failed
    end
    
  rescue RegexpError => details
    raise RegexpError, "Choked while '#{@scanner}' was trying to match '#{string}' : #{details}"
  end

end