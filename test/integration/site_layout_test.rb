require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  # レイアウトのリンクに対してのテスト
  test "layout links" do
    # rootを開く
    get root_path
    # homeテンプレートが表示されているかチェック
    assert_template 'static_pages/home'
    # root_pathのリンクが２つあるかチェック
    assert_select "a[href=?]", root_path, count: 2
    # help_pathのリンクがあるかチェック
    assert_select "a[href=?]", help_path
    # about_pathのリンクがあるかチェック
    assert_select "a[href=?]", about_path
    # contact_pathのリンクがあるかチェック
    assert_select "a[href=?]", contact_path

    get contact_path
    assert_select "title", full_title("Contact")

  end

end
