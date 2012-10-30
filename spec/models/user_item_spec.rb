require 'spec_helper'

describe UserItem do
  before do
    @user = FactoryGirl.create :user
    @item2 = FactoryGirl.create :item, reputation_bonus: 100
    @item = FactoryGirl.create :item, reputation_bonus: 100, upgrade: @item2
  end
  context 'place_item' do
    it 'should put item in place if its free' do
      @user.update_attribute :coins, 10
      @uitem = @user.buy_item @item, :coins
      @user.place_item(@uitem, 1, 1).should be_true
      @uitem.reload
      [ @uitem.x, @uitem.y ].should == [ 1, 1 ]
    end
    it 'should return false if place is busy' do
      @user.update_attribute :coins, 20
      @uitem = @user.buy_item @item, :coins
      @user.place_item(@uitem, 1, 1)
      @uitem2 = @user.buy_item @item, :coins
      @user.place_item(@uitem2, 1, 1).should be_false
    end
    it 'should increase user reputation' do
      @user.update_attribute :coins, 10
      @uitem = @user.buy_item @item, :coins
      @user.reload.reputation_bonus.should == 100
    end
  end
  context 'upgrade' do
    it 'should replace the item' do
      @user.update_attribute :coins, 10
      @uitem = @user.buy_item @item, :coins
      @newitem = @uitem.upgrade
      @newitem.should be_a UserItem
      @newitem.item.should == @item2
    end
  end
end
