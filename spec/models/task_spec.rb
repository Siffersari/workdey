require "rails_helper"

RSpec.describe Task, type: :model do
  before :each do
    @user = create(:user, user_attr.merge(user_type: "artisan"))
    create(:user, user_attr.merge(user_type: "artisan"))
    @skillset = create(:skillset)
    @user.skillsets << @skillset
  end

  describe ".current_user_city_street" do
    context "should set the user address given the right user email" do
      it do
        expect(Task.current_user_city_street(@user.email)).
          to eq "%#{@user.street_address}%"
      end
    end
  end

  describe ".get_artisans_nearby" do
    let(:artisan) { User.all }
    it "should return two artisans that match the exact city and street " do
      expect(Task.get_artisans_nearby(
        artisan,
        @user.street_address.downcase,
        @user.city.downcase
      ).count).to eq 1
    end
  end

  describe ".get_artisans" do
    context "return nil when the wrong keyword is passed" do
      it { expect(Task.get_artisans("Marketting", @user.email)).to eq nil }
    end
    context "returns an array of artisans nearby with the correct Keyword" do
      it { expect(Task.get_artisans(@skillset.name, @user.email).count).to eq 1 }
    end
  end

  describe ".search_for_available_need" do
    let(:price_range) do
      [
        Faker::Commerce.price(2000..3000).to_s,
        Faker::Commerce.price(3001..5000).to_s
      ]
    end
    let(:skillset) { create(:skillset) }
    let(:skillset2) { create(:skillset) }
    let!(:task1) do
      create(
        :task,
        skillset_id: skillset.id,
        tasker_id: @user.id,
        price_range: price_range
      )
    end
    let!(:task2) do
      create(
        :task,
        skillset_id: skillset.id,
        tasker_id: @user.id,
        price_range: price_range,
        start_date: Date.yesterday
      )
    end

    context "when searching for a need that has a task" do
      it "returns an array containing  the number of available task" do
        expect(Task.search_for_available_need(skillset.name).count).to eq 1
      end

      it "doesn't return tasks that the start date is in the past" do
        expect(
          Task.search_for_available_need(skillset.name)
        ).not_to include task2
      end
    end

    context "when searching for a need that has no task" do
      it "returns an empty array " do
        expect(Task.search_for_available_need(skillset2.name)).to eq []
      end
    end
  end
end
