module Slimmer::Processors
  class ConditionalCommentMover
    def filter(src, dest)
      src.xpath("//comment()").each do |comment|
        if match_conditional_comments(comment)
          dest.at_xpath("/html/head") << comment
        end
      end
    end

    def match_conditional_comments(str)
      str.to_s =~ /<!--\[[A-Za-z0-9 ]+\]>(.*)<!\[endif\]-->/m
    end
  end
end
