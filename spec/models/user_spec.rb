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
          @uitem = @user.buy_item(@item, :coins)
          @uitem.should be_false
        end

        it 'should return useritem and take users coins' do
          @user.update_attribute :coins, 10
          @uitem = @user.buy_item(@item, :coins)
          @uitem.should be_a UserItem
          @uitem.user.should == @user
          @user.reload.user_items.count.should == 1
          @user.reload.coins.should == 0
        end
      end

      context 'money' do
        it 'should return false if not enough resources' do
          @uitem = @user.buy_item(@item, :money)
          @uitem.should be_false
        end

        it 'should return useritem and take users coins' do
          @user.update_attribute :money, 10
          @uitem = @user.buy_item(@item, :money)
          @uitem.should be_a UserItem
          @uitem.user.should == @user
          @user.reload.user_items.count.should == 1
          @user.reload.money.should == 0
        end
      end

      it 'should check requirements - level - not met' do
        @user.update_attribute :money, 10
        @item.requirements[:level] = 3
        @uitem = @user.buy_item(@item, :money)
        @uitem.should be_false
      end

      it 'should check requirements - level - met' do
        @user.update_attribute :money, 10
        @user.update_attribute :level, 4
        @item.requirements[:level] = 3
        @item.save
        @uitem = @user.buy_item(@item, :money)
        @uitem.should be_a UserItem
      end

      it 'should check requirements - item - not met' do
        @user.update_attribute :money, 10
        @item2 = FactoryGirl.create :item
        @item2.requirements[:items] = [ @item.id ]
        @item2.save
        @uitem = @user.buy_item(@item2, :money)
        @uitem.should be_false
      end

      it 'should check requirements - item - not met' do
        @user.update_attribute :money, 20
        @item2 = FactoryGirl.create :item
        @item2.requirements[:items] = [ @item.id ]
        @item2.save
        @uitem = @user.buy_item(@item, :money)
        @uitem = @user.buy_item(@item2, :money)
        @uitem2.should be_a UserItem
      end

      it 'should give rewards' do
        @user.update_attribute :money, 10
        @item.rewards[:experience] = 100
        @item.save
        @uitem = @user.buy_item(@item, :money)
        @user.reload.experience.should == 100
      end

      it 'should store a new useritem at warehouse (-1, -1 coords)' do
        @user.update_attribute :coins, 10
        @uitem = @user.buy_item @item, :coins
        [ @uitem.x, @uitem.y ].should == [ -1, -1 ]
      end
    end
  end
end
