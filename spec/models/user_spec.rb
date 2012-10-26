require 'spec_helper'

describe User do
  before do
    @user = FactoryGirl.create :user
    @item = FactoryGirl.create :item
  end
  context 'item shopping' do
    context 'buy_item' do

      context 'coins' do
        it 'should return false if not enough resources' do
          @uitem = @user.buy_item(Item, :coins)
          @uitem.should be_false
        end

        it 'should return useritem and take users coins' do
          @user.update_attribute :coins, 10
          @uitem = @user.buy_item(Item, :coins)
          @uitem.should be_a UserItem
          @uitem.user.should == @user
          @user.reload.user_items.count.should == 1
          @user.reload.coins.should == 0
        end
      end

      context 'money' do
        it 'should return false if not enough resources' do
          @uitem = @user.buy_item(Item, :money)
          @uitem.should be_false
        end

        it 'should return useritem and take users coins' do
          @user.update_attribute :money, 10
          @uitem = @user.buy_item(Item, :money)
          @uitem.should be_a UserItem
          @uitem.user.should == @user
          @user.reload.user_items.count.should == 1
          @user.reload.money.should == 0
        end
      end

      it 'should store a new useritem at warehouse (-1, -1 coords)' do
        @user.update_attribute :coins, 10
        @uitem = @user.buy_item Item, :coins
        [ @uitem.x, @uitem.y ].should == [ -1, -1 ]
      end
    end
  end
end
