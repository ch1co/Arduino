
/**
 * 
 * @author Ido Nidbach & Michael Winkler
 * @date - 15/07/21
 * This program is used to skip ads at the beginning of the video and close text ads the pop up.
 * TO DO: - Fix - when there's an ad in the middle of the youtube video it restarts the video 
 		  and returns to the start of it instead of the point it stopped.
 	
 */

/**
 * Imports
 */

import java.awt.AWTException;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.List;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.openqa.selenium.By;
import org.openqa.selenium.Dimension;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.Point;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;
import java.io.File;

public class Program {

	/**
	 * Class variables
	 */

	/**
	 	Please notice the comment about changing the web-driver to your desired one
		in the "createDriver()" method.
	 */
	 

	// Filename will be auto-generated after the video has finished playing.
	private static String filename = "";

	// Set the full path to the directory you would like to save the report to.
	private static String path = "/home/ch1co/Documents/";

	// Change the url to the youtube video you would like to have a report about.
	private static String url = "https://www.youtube.com/watch?v=qgL7NrduGJc";

	private static final String skip = "&t=3s";
	private static final SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy hh:mm:ss");
	private static long startAd = 0;
	private static long videoStart = 0;
	private static long videoCheck = 0;
	private static int vidTime = 0;
	private static List<String> actionList = new ArrayList<String>();
	private static List<Long> timeList = new ArrayList<Long>();
	private static WebElement totalVidTime;
	private static FirefoxDriver fDriver;
	private static Calendar cal;

	/**
	 * 
	 * @param d - Driver
	 * @return - This method will return the total time of the youtube video.
	 */

	public static int getTotalVideoSeconds(FirefoxDriver d) {

		int total = 0;

		if (!d.findElements(By.className("ytp-time-duration")).isEmpty()) {
			totalVidTime = d.findElement(By.className("ytp-time-duration"));
			videoCheck = System.currentTimeMillis();
			String time = totalVidTime.getText();
			String[] timeStamp = time.split(":");
			for (int i = 0; i < timeStamp.length; i++) {
				if (i == timeStamp.length - 1) {
					total += Integer.parseInt(timeStamp[timeStamp.length - 1]);
				} else {
					total += Integer.parseInt(timeStamp[i]) * 60;
				}
			}

			return total;
		}
		return total;
	}

	/**
	 * 
	 * @param d - Driver
	 * @return - This method will close the text add appearing in the video-player
	 *         and return true after.
	 */

	public static boolean checkForTextAds(FirefoxDriver d) {

		WebElement annoyingCloseBtn = null;
		boolean annoy = false;
		if (!d.findElementsByClassName("ytp-ad-overlay-close-button").isEmpty()) {
			annoyingCloseBtn = (WebElement) d.findElement(By.className("ytp-ad-overlay-close-button"));
			annoy = true;
			startAd = System.currentTimeMillis();
		}

		if (annoyingCloseBtn != null) {
			JavascriptExecutor executor = (JavascriptExecutor) d;
			executor.executeScript("arguments[0].click();", annoyingCloseBtn);
			// lst.add((startAd - videoStart) / 1000);
			actionList.add("Text ad closed.");
			timeList.add((startAd - videoStart) / 1000);
		}

		return annoy;

	}

	/**
	 * 
	 * @param d - Driver
	 * @return - This method will close the video ad appearing on the screen and
	 *         return true after.
	 */

	public static boolean checkAds(FirefoxDriver d) {

		for (int i = 0; i < 52; i++) {
			char j = (char) (i + 67);
			if (!d.findElements(By.xpath("//*[@id=\"button:" + (j++) + "\"]")).isEmpty()) {
				startAd = System.currentTimeMillis();
				d.navigate().refresh();
				actionList.add("Ad skiped using\nrefresh of the page");
				timeList.add((startAd - videoStart) / 1000);

				return true;
			}
		}

		return false;

	}

	/**
	 * This method is used to click on whatever play button appears inside the video
	 * player.
	 * 
	 * @param d - Driver
	 */

	public static void setPlayBtn(FirefoxDriver d) {
		if (d.findElement(By.cssSelector(".ytp-play-button")) != null) {
			WebElement playBtn = d.findElement(By.cssSelector(".ytp-play-button"));
			playBtn.click();
			videoStart = System.currentTimeMillis();
			videoCheck = System.currentTimeMillis();

			actionList.add("Play button clicked.");
			timeList.add((videoCheck - videoStart) / 1000);

			return;
		}
		if (d.findElement(By.cssSelector(".ytp-large-play-button")) != null) {
			WebElement playBtn = d.findElement(By.cssSelector(".ytp-large-play-button"));
			playBtn.click();

			videoStart = System.currentTimeMillis();
			videoCheck = System.currentTimeMillis();
			actionList.add("Play button clicked.");
			timeList.add((videoCheck - videoStart) / 1000);

			return;
		}

	}

	/**
	 * This method is used to mute the youtube video.
	 * 
	 * @param d - Driver.
	 */

	public static void muteVideo(FirefoxDriver d) {
		if (d.findElement(By.cssSelector(".ytp-mute-button")) != null) {
			WebElement muteBtn = d.findElement(By.cssSelector(".ytp-mute-button"));
			muteBtn.click();
			videoCheck = System.currentTimeMillis();
			actionList.add("Volume muted.");
			timeList.add((videoCheck - videoStart) / 1000);

			return;
		}
		return;
	}

	/**
	 * This method is used to skip the ad appearing in the youtube video using
	 * "&t=3s"
	 * 
	 * @param d - Driver
	 */

	public static void skipAd(FirefoxDriver d) {
		startAd = System.currentTimeMillis();
		d.navigate().to(url + skip);
		actionList.add("Ad skiped using : " + skip);
		timeList.add((startAd - videoStart) / 1000);
	}

	/**
	 * This method is used to run all the checks.
	 * 
	 * @param d - Driver
	 */

	public static void runner(FirefoxDriver d) {
		vidTime = getTotalVideoSeconds(d);
		do {
			do {
				if (videoCheck <= (videoStart + 30000) && checkAds(d)) {
					skipAd(d);
				}
				checkAds(d);
				checkForTextAds(d);
				videoCheck = System.currentTimeMillis();
				// getVidTime(d);
			} while (videoCheck < (videoStart + 60000));

			checkForTextAds(d);

		} while (((videoCheck - videoStart) / 1000) < vidTime);
	}

	/**
	 * This method is used to create an xlsx file, each time the program will run,
	 * the file name will be "youtube" + the current date and time.
	 */

	public static void createSheet() {
		try {
			cal = new GregorianCalendar();
			dateFormat.setTimeZone(cal.getTimeZone());
			filename = "youtube-" + dateFormat.format(cal.getTime()) + ".xlsx";
			path = "/home/ch1co/Documents/";
			FileOutputStream fos = new FileOutputStream(path + filename);

			XSSFWorkbook workbook = new XSSFWorkbook();
			XSSFSheet sheet = workbook.createSheet();

			Row row = sheet.createRow(0);
			CellStyle style = workbook.createCellStyle();
			style.setFillForegroundColor(IndexedColors.LEMON_CHIFFON.getIndex());
			style.setFillPattern(FillPatternType.BRICKS);
			style.setAlignment(HorizontalAlignment.CENTER);
			style.setBorderTop(BorderStyle.MEDIUM);
			style.setBorderBottom(BorderStyle.MEDIUM);
			style.setBorderLeft(BorderStyle.MEDIUM);
			style.setBorderRight(BorderStyle.MEDIUM);
			row.createCell(0).setCellValue("action taken");
			row.createCell(1).setCellValue("seconds after video");
			row.getCell(0).setCellStyle(style);
			row.getCell(1).setCellStyle(style);
			workbook.write(fos);
			fos.flush();
			fos.close();
			workbook.close();
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
	}

	/**
	 * This method is used to insert the data into the excel sheet and set the
	 * "styles".
	 */

	public static void insertDataToSheet() {
		try {
			File report = new File(path + filename);
			FileInputStream fis = new FileInputStream(report);

			XSSFWorkbook workbook = new XSSFWorkbook(fis);
			XSSFSheet sheet = workbook.getSheetAt(0);

			// Adjust styles
			sheet.setColumnWidth(0, 10000);
			sheet.setColumnWidth(1, 10000);
			sheet.setDefaultRowHeight((short) 500);

			CellStyle style = workbook.createCellStyle();
			style.setFillForegroundColor(IndexedColors.AQUA.getIndex());
			style.setFillPattern(FillPatternType.BRICKS);
			style.setAlignment(HorizontalAlignment.CENTER);
			style.setBorderTop(BorderStyle.MEDIUM);
			style.setBorderBottom(BorderStyle.MEDIUM);
			style.setBorderLeft(BorderStyle.MEDIUM);
			style.setBorderRight(BorderStyle.MEDIUM);

			// Insert Data
			for (int i = 0; i < actionList.size(); i++) {
				int newRowIndex = sheet.getLastRowNum() + 1;
				XSSFRow newRow = sheet.createRow(newRowIndex);
				for (int j = 0; j < 2; j++) {
					Cell cell = newRow.createCell(j);
					cell.setCellStyle(style);
					if (j == 0) {
						cell.setCellValue(actionList.get(i));
					} else {
						cell.setCellValue(timeList.get(i));
					}

				}

			}
			FileOutputStream fos = new FileOutputStream(report);
			workbook.write(fos);
			fis.close();
			fos.close();
			workbook.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * This method is used to create a WebDriver, in this case firefox.
	 */

	public static void createDriver() {
		// Change the path to your geko or chrome driver executable and set the
		// properties accordingly.
		System.setProperty("webdriver.gecko.driver", "/usr/local/bin/geckodriver");
		fDriver = new FirefoxDriver();
		fDriver.manage().window().setPosition(new Point(0, 0));
		fDriver.manage().window().setSize(new Dimension(750, 800));
		fDriver.get(url);
	}

	public static void main(String[] args) throws InterruptedException, AWTException {
		// Initiate web driver.
		createDriver();

		// Start the video
		setPlayBtn(fDriver);

		// lower video volume
		muteVideo(fDriver);

		// Run the checks for ads
		runner(fDriver);

		// Generate the excel sheet
		createSheet();

		// Inserting data to sheet
		insertDataToSheet();

		// Close driver.
		fDriver.close();

	}

}
