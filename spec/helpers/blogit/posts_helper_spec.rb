# -*- coding: utf-8 -*-
require "spec_helper"

describe Blogit::PostsHelper do

  describe :blog_post_tag do

    it "should create a tag element and give it a 'blog_post... prefixed class" do
      helper.blog_post_tag(:div, "hello", id: "blog_div", class: "other_class").should == %{<div class="other_class blog_post_div" id="blog_div">hello</div>}
      helper.blog_post_tag(:li, "hello", id: "blog_li").should == %{<li class="blog_post_li" id="blog_li">hello</li>}
    end

  end

  describe :comments_for do
    let(:post) { FactoryGirl.create :post }

    it "should be empty if comments are not configured" do
      Blogit.configure do |config|
        config.include_comments = :no
      end

      helper.expects(:render).with(partial: "blogit/posts/no_comments", locals: {post: post, comment: comment=post.comments.new})
      helper.comments_for(post, comment)
    end

    it "should be full html when comments use active record" do
      Blogit.configure do |config|
        config.include_comments = :active_record
      end

      helper.expects(:render).with(partial: "blogit/posts/active_record_comments", locals: {post: post, comment: comment=post.comments.new})
      helper.comments_for(post, comment)
    end
  end

  describe :blog_post_archive do

    before :each do
      Post.delete_all
    end
    after :each do
      Post.delete_all
    end


    it "should create an ul tag tree with years, monthes and articles" do
      dec_2011 = FactoryGirl.create(:post, title: "Great post 1", created_at: Time.new(2011, 12, 25))
      july_2012_1 = FactoryGirl.create(:post, title: "Great Post 2", created_at: Time.new(2012,7,14))
      july_2012_2 = FactoryGirl.create(:post, title: "Great Post 3", created_at: Time.new(2012,7,28))
      sept_2012 = FactoryGirl.create(:post, title: "Great Post 4", created_at: Time.new(2012,9, 3))

      year_css = "archive-years"
      month_css = "archive-month"
      post_css = "archive-post"

      helper.blog_posts_archive_tag(year_css, month_css, post_css).should == ["<ul class=\"#{year_css}\">",
                                                                                "<li><a onclick=\"toggleBrothersDisplay(this, 'UL')\">2011</a>",
                                                                                  "<ul class=\"#{month_css}\">",
                                                                                    "<li><a onclick=\"toggleBrothersDisplay(this, 'UL')\">December</a>",
                                                                                      "<ul class=\"#{post_css}\">",
                                                                                        "<li><a href=\"#{blogit.post_path(dec_2011)}\">#{dec_2011.title}</a></li>",
                                                                                      "</ul>",
                                                                                    "</li>",
                                                                                  "</ul>",
                                                                                "</li>",
                                                                                "<li><a onclick=\"toggleBrothersDisplay(this, 'UL')\">2012</a>",
                                                                                  "<ul class=\"#{month_css}\">",
                                                                                    "<li><a onclick=\"toggleBrothersDisplay(this, 'UL')\">July</a>",
                                                                                      "<ul class=\"#{post_css}\">",
                                                                                        "<li><a href=\"#{blogit.post_path(july_2012_1)}\">#{july_2012_1.title}</a></li>",
                                                                                        "<li><a href=\"#{blogit.post_path(july_2012_2)}\">#{july_2012_2.title}</a></li>",
                                                                                      "</ul>",
                                                                                    "</li>",
                                                                                    "<li><a onclick=\"toggleBrothersDisplay(this, 'UL')\">September</a>",
                                                                                      "<ul class=\"#{post_css}\">",
                                                                                        "<li><a href=\"#{blogit.post_path(sept_2012)}\">#{sept_2012.title}</a></li>",
                                                                                      "</ul>",
                                                                                    "</li>",
                                                                                  "</ul>",
                                                                                "</li>",
                                                                              "</ul>"].join
    end

    it "should escape html in titles" do
      post = FactoryGirl.create(:post, title: ">Great Post with html characters<", created_at: Time.new(2012,9, 3))

      archive_tag = helper.blog_posts_archive_tag('y','m','p')

      archive_tag.should_not include(post.title)
      archive_tag.should include(CGI.escape_html(post.title))
    end

    it "should be a safe html string" do
      helper.blog_posts_archive_tag('y','m','p').should be_html_safe
    end

  end

end
