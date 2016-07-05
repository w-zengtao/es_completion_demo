class Article < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name 'es_completion_demo'
  document_type 'article'

  mapping do
    indexes :keyword
    indexes :keyword_suggest, type: 'completion', payloads: true
  end

  def as_indexed_json(options = {})
    as_json.merge \
    keyword_suggest: {
      input:  keyword,
      output: keyword
    }
  end

  def self.es_typeahead(q)
    Article.__elasticsearch__.client.suggest(
      index: Article.index_name,
      body: {
        articles: {
          text: q,
          completion: {
            field: 'keyword_suggest',
            size: 10
          }
        }
      }
    )
  end

  # Article.delete_all
  # Article.create title: 'Foo'
  # Article.create title: 'Bar'
  # Article.create title: 'Foo Foo'
  # Article.__elasticsearch__.refresh_index!

end
