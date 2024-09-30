package org.scoula.stock;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.PropertySource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.List;

@Controller
@Slf4j
@RequestMapping("/stock")
@PropertySource({"classpath:/application.properties"})
public class StockController {

    @Value("${stock.url}")
    private String apiUrl;

    @Value("${openAPI.key}")
    private String key;

    private final StockService stockService;

    public StockController(StockService stockService) {
        this.stockService = stockService;
    }

    // 가장 가까운 평일을 매개변수로
//    private String getClosestPastWeekday() {
//        LocalDate today = LocalDate.now();
//        // Check if today is a weekend
//        if (today.getDayOfWeek() == DayOfWeek.SATURDAY) {
//            return today.minusDays(1).toString();  // Move to Friday
//        } else if (today.getDayOfWeek() == DayOfWeek.SUNDAY) {
//            return today.minusDays(2).toString();  // Move to Friday
//        } else {
//            return today.toString();  // It's a weekday, return today
//        }
//    }

    @GetMapping(value = "/update", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> getStockDataAndUpdateDB() {
        ExecutorService executorService = Executors.newFixedThreadPool(20);
        try {
            // Retrieve stock information from the database
            List<StockVO> stocks = stockService.getAllStocks();

            // 각 주식에 대한 작업(task)을 준비
            List<Callable<Void>> tasks = stocks.stream().map(stock -> (Callable<Void>) () -> {
                try {
                    // API 요청 URL을 준비
                    String requestUrl = apiUrl + "?serviceKey=" + key +
                            "&numOfRows=1" +     // 페이지 당 결과 수
                            "&pageNo=1" +         // 페이지 번호
                            "&resultType=json" +   // 응답 형식 (JSON)
                            "&basDt=20240902" +
                            "&isinCd=" + stock.getStandardCode();  // 한국 주식 코드

                    // HttpURLConnection을 사용하여 API 요청을 실행
                    URL url = new URL(requestUrl);
                    log.info(url.toString());
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.setRequestMethod("GET");
                    conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");

                    int responseCode = conn.getResponseCode();
                    log.info("Response code for stock {}: {}", stock.getKoreanStockName(), responseCode);

                    // 응답 코드에 따라 스트림 선택 (정상 응답 또는 오류 스트림)
                    BufferedReader rd;
                    if (responseCode >= 200 && responseCode <= 300) {
                        rd = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
                    } else {
                        rd = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));
                    }

                    // API 응답을 읽음
                    StringBuilder sb = new StringBuilder();
                    String line;
                    while ((line = rd.readLine()) != null) {
                        sb.append(line);
                    }
                    rd.close();
                    conn.disconnect();

                    // JSON을 파싱하고 필요한 데이터를 추출
                    String responseBody = sb.toString();
                    log.info("Response Body for stock {}: {}", stock.getKoreanStockName(), responseBody);

                    try {
                        ObjectMapper objectMapper = new ObjectMapper();
                        JsonNode rootNode = objectMapper.readTree(responseBody);
                        JsonNode items = rootNode.path("response").path("body").path("items").path("item");

                        // 각 항목에 대해 데이터를 추출
                        for (JsonNode item : items) {
                            // 값을 추출
                            String standardCode = item.path("isinCd").asText();  // ISIN 코드
                            String price = item.path("clpr").asText();  // 종가

                            // standardCode를 키로 하여 데이터베이스를 업데이트
                            stockService.updateStockData(price, standardCode); // 데이터베이스 업데이트
                        }
                    } catch (Exception jsonEx) {
                        log.error("Error parsing JSON response for stock {}: {}", stock.getKoreanStockName(),
                                jsonEx.getMessage());
                        // 이 주식은 건너뛰고 다음 주식으로 넘어감
                    }

                } catch (Exception e) {
                    log.error("Error occurred while fetching stock data for stock {}: {}", stock.getKoreanStockName(),
                            e.getMessage());
                    // 이 주식은 건너뛰고 다음 주식으로 넘어감
                }
                return null;
            }).toList();

            // 작업을 스레드 풀에 제출하고 모든 작업이 완료되기를 기다림
            List<Future<Void>> futures = executorService.invokeAll(tasks);

            // 모든 작업이 완료되었는지 확인
            for (Future<Void> future : futures) {
                try {
                    future.get();  // 작업이 완료될 때까지 대기
                } catch (Exception e) {
                    log.error("Error occurred while processing a stock update", e);
                }
            }

            // 성공 응답 반환
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            return new ResponseEntity<>("Stock prices updated successfully", headers, HttpStatus.OK);

        } catch (Exception e) {
            log.error("Error occurred while fetching stock data and updating DB", e);
            return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        } finally {
            // 스레드 풀 종료
            executorService.shutdown();
        }
    }

}
