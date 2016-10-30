require "spec_helper"

require "pry"

describe Petsonic do
  before(:all) do
    url = "http://www.petsonic.com/es/perros/snacks-y-huesos-perro"
    @filename = "/tmp/output.csv"

    @reader = Petsonic::Reader.new(url, @filename)
    @reader.parse
    @reader.store!
  end

  let(:filename) { @filename }
  let(:objects) { @reader.items }

  it "should return list of the shopping items" do
    expect(objects).to be_a(Array)
    expect(objects.size).to eq(207)
  end

  it "should return the product details" do
    expect(objects[0].title).to eq("Barritas Redonda de Ternera para Perro")
    expect(objects[0].picture).to eq("http://www.petsonic.com/3121-large_default/hobbit-half-barritas-redonda-de-ternera.jpg")
    expect(objects[0].price).to eq("4.20 €")
    expect(objects[0].weight).to eq("400 Gr.")
    expect(objects[1].title).to eq("Barritas Redonda de Ternera para Perro")
    expect(objects[1].picture).to eq("http://www.petsonic.com/3121-large_default/hobbit-half-barritas-redonda-de-ternera.jpg")
    expect(objects[1].price).to eq("7.80 €")
    expect(objects[1].weight).to eq("1 Kg.")
  end

  it "should store the items to output" do
    lines = File.readlines(filename)
    expect(lines[0].strip).to eq("Title,Picture,Price")
    expect(lines[1].strip).to eq("Barritas Redonda de Ternera para Perro - 400 Gr.,http://www.petsonic.com/3121-large_default/hobbit-half-barritas-redonda-de-ternera.jpg,4.20 €")
    expect(lines[2].strip).to eq("Barritas Redonda de Ternera para Perro - 1 Kg.,http://www.petsonic.com/3121-large_default/hobbit-half-barritas-redonda-de-ternera.jpg,7.80 €")
  end
end
