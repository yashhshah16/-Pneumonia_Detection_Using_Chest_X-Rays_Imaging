library(shiny)
#library(reticulate)
use_condaenv("myenv")
source_python('cnn_prediction.py')
py_install('pandas')
conda_create("r-reticulate")
#add(5, 10)
ui <- fluidPage(
  titlePanel("Multiple file uploads"),
  sidebarLayout(
    sidebarPanel(
      fileInput(inputId = "image_upload",
                label="Upload Image here",
                #label = "Chest X-Ray Images",
                #accept =  'image/jpeg',
                multiple = TRUE)
    ),
    mainPanel(
     # textOutput("img"),
      imageOutput("img_output")
    )
  )
)
server <- function(input, output) {
  #mycsvs<-reactive({
    #rbindlist(lapply(input$csvs$datapath, fread),
              #use.names = TRUE, fill = TRUE)
  #})
  #output$count <- renderText(nrow(mycsvs()))
  files <- reactive({
    files <- input$image
    files$datapath <- gsub("\\\\", "/", files$datapath)
    files
  })
  observeEvent(input$image_upload, {
    in_file <- input$image_upload
    if(is.null(in_file))
      return(list(src=""))
    # file.copy(in_file$datapath, file.path('.', in_file$name))
    pred <- predict(in_file$datapath)
    if(pred == 'pos') {
      # reactive binding to render prediction result
      output$pred_result <- renderPrint("Positive")
    } else {
      output$pred_result <- renderPrint("Negative")
    }
    # reactive binding to render image
    output$img_output <- renderImage({
      list(src=in_file$datapath)}, deleteFile = T)
  })
  
}

shinyApp(ui = ui, server = server)
