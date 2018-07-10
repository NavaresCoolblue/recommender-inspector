library(jpeg)
library(coolblueshiny)
library(RCurl)

IMAGEMAPPING = read.csv('productid_imageid.csv')
as_of_date = '2018-07-03'
project = 'coolblue-bi-platform-prod'

get_recommender_sequences = function(project, as_of_date){
  dataset = 'recommender_systems'
  datatable = 'ga_product_sequence_most_recent'
  
  query = sprintf('SELECT identity_role_id, product_sequence FROM %s.%s WHERE
                  insert_datetime = "%s 00:00:00"', 
                  dataset, datatable, as_of_date)
  
  seq = query_exec_fixed(query, project=project, max_pages=Inf, use_legacy_sql = FALSE)  
  return(seq)
}

get_recommender_recommendations = function(project, as_of_date){
  dataset = 'recommender_systems'
  datatable = 'recommended_products'
  
  query = sprintf('SELECT * FROM %s.%s WHERE
                  _PARTITIONTIME = "%s 00:00:00"', 
                  dataset, datatable, as_of_date)
  
  rec = query_exec_fixed(query, project=project, max_pages=Inf, use_legacy_sql = FALSE)  
  return(rec)
}

get_image = function(img_mapping){
  url = sprintf('https://image.coolblue.nl/products/%s', img_mapping)
  return(paste0('<img src=\"', url, '\" width=\"96\" height=\"128\">'))
}


server = function(input, output, session) {
  sequences = get_recommender_sequences(project, as_of_date)
  recommendations = get_recommender_recommendations(project, as_of_date)
  
  session_id = sample(sequences[, 1], 100)
  output$session_drill_down = renderUI({
    selectInput("sessionId", "Session Id: ", session_id)
  })
  
  output$sequence = renderText({
    sess = as.numeric(input$sessionId)
    seq = sequences$product_sequence[sequences$identity_role_id == sess]
    seq = as.numeric(unlist(strsplit(seq, ',')))
    seq_img = c()
    for (i in seq){
      seq_img = c(seq_img, IMAGEMAPPING$MAINIMAGEID[IMAGEMAPPING$PRODUCTID == i])
    }
    html_seq = ''
    for (i in seq_img){
      html_seq = paste0(html_seq, get_image(i))  
    } 
    html_seq
  })
  
  output$recommendation = renderText({
    sess = as.numeric(input$sessionId)
    rec = recommendations$products[recommendations$account_id == sess]
    rec = as.numeric(unlist(strsplit(rec, ',')))
    rec_img = c()
    for (i in rec){
      rec_img = c(rec_img, IMAGEMAPPING$MAINIMAGEID[IMAGEMAPPING$PRODUCTID == i])
    }
    html_rec = ''
    for (i in rec_img){
      html_rec = paste0(html_rec, get_image(i))  
    } 
    html_rec
  })
} 

