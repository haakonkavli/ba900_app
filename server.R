# Server tool for BA 900 plot and export app



# Prepare libraries and data ----------------------------------------------


library(shiny)
library(data.table)
library(RMySQL)
library(ggplot2)

load('ba900_data.Rdata')  # Prepared by running dp_to_rdata_export.R


# Server begins: ----------------------------------------------------------


shinyServer(function(input, output, session) {

    exportData <- reactive({

        if (input$ratio_check == 'Ratio') {

            numerator <- ba[bank %in% input$select_bank & item %in% input$select_item]

            numerator <- dcast(numerator, 'datestamp + bank ~ ItemName', value.var = 'value')

            denom <- ba[bank %in% input$select_bank & item %in% input$select_denominator]

            denom <- denom[,.(datestamp, bank, denominator = value)]

            plot_data <- merge(denom, numerator, by = c('datestamp','bank'))

            plot_data <- melt(plot_data, id.vars = c('datestamp', 'bank', 'denominator'))

            plot_data$value <- plot_data$value / plot_data$denominator

            setnames(plot_data,'variable','ItemName')


        } else {

            plot_data <- ba[datestamp >= input$dates_start & datestamp <= input$dates_end & bank %in% input$select_bank & item %in% input$select_item]

        }

        plot_data <- plot_data[datestamp >= input$dates_start & datestamp <= input$dates_end]



        return(plot_data)

    })

    output$select_ratio_check_ui <- renderUI({
        radioButtons(inputId = 'ratio_check',
                     label = 'Plot data as ratio or Rand amount?',
                     choices = c('Ratio','Rand'),
                     selected = 'Rand')
    })


    output$export_path_ui <- renderUI({


            textInput(inputId = 'export_path',
                      label = 'Path to Folder:',
                      value = "H:/")

    })

    output$export_name_ui <- renderUI({

            textInput(inputId = 'export_name',
                      label = 'File name:',
                      value = "BA900 Data")


    })

    output$export_button_ui <- renderUI({

            actionButton(inputId = 'export_button',
                         label = 'Save Data')

    })

    output$select_bank_ui <- renderUI({

        checkboxGroupInput(inputId = 'select_bank',
                           label = 'Banks',
                           choices = c(Total = 'TOT',
                                       Absa = 'ASA',
                                       `Standard Bank` = 'SBK',
                                       Firstrand = 'FSR',
                                       Nedbank = 'NED',
                                       Investec = 'INL',
                                       Capitec = 'CPI',
                                       `African Bank` = 'ABL'),

                           selected = 'TOT',
                           inline = F)

    })
    output$select_ratio_ui <- renderUI({

        if (input$ratio_check == 'Ratio') {
            selectInput(inputId = 'select_denominator',
                        label = 'Plot as Ratio of:',
                        choices = ba_select_items,
                        selected = 277
            )
        }


    })


    output$select_item_ui <- renderUI({

        checkboxGroupInput(inputId = 'select_item',
                           label = 'Select Line Items',
                           choices = ba_select_items,
                           selected = 1,
                           inline = F)
    })


    output$baplot <- renderPlot({

        plot_data <- exportData()

        ggplot(plot_data, aes(x = as.Date(datestamp), y = value, color = bank)) +
            geom_line() +
            facet_wrap(~ItemName, scales = 'free') + ylab('Rand Billions') + xlab('')


    })

    output$downloadData <- downloadHandler(
        filename = function() { 'BA900 Download.csv' },
        content = function(file) {
            write.csv(dcast(exportData(),'datestamp ~ bank + ItemName', sep = ' ', value.var = 'value'), file)
        }
    )


})
