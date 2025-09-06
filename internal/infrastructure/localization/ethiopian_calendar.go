package localization

import (
	"fmt"
	"time"
)

// EthiopianDate holds converted Ethiopian calendar date parts.
type EthiopianDate struct {
	Year  int
	Month int
	Day   int
}

// ToEthiopian converts a Gregorian time.Time to Ethiopian calendar date.
// Algorithm based on the 8-year cycle difference (Ethiopian year starts on Sept 11 Gregorian
// or Sept 12 in Gregorian leap years). This is a simplified conversion sufficient for
// displaying a localized date string YYYY-MM-DD. It does not handle historical calendar reforms.
func ToEthiopian(t time.Time) EthiopianDate {
	// Determine Ethiopian year (adjusted offset to 7 to correct year display)
	gYear, _, _ := t.Date()
	ethYear := gYear - 7
	// Ethiopian new year in Gregorian
	newYear := time.Date(gYear, time.September, 11, 0, 0, 0, 0, t.Location())
	// In Gregorian leap year Ethiopian new year shifts to Sept 12
	if isGregorianLeap(gYear) {
		newYear = time.Date(gYear, time.September, 12, 0, 0, 0, 0, t.Location())
	}
	if t.Before(newYear) {
		ethYear -= 1
		// Recompute previous year's new year to calculate month/day offset
		prevYear := gYear - 1
		prevNewYear := time.Date(prevYear, time.September, 11, 0, 0, 0, 0, t.Location())
		if isGregorianLeap(prevYear) {
			prevNewYear = time.Date(prevYear, time.September, 12, 0, 0, 0, 0, t.Location())
		}
		return buildEthiopianDate(t, prevNewYear, ethYear)
	}
	return buildEthiopianDate(t, newYear, ethYear)
}

func buildEthiopianDate(t time.Time, ethNewYear time.Time, ethYear int) EthiopianDate {
	days := int(t.Sub(ethNewYear).Hours() / 24) // days since Ethiopian new year
	// Ethiopian months: 1-12 = 30 days, 13th (Pagumen) = 5 or 6 days
	month := days/30 + 1
	day := days%30 + 1
	return EthiopianDate{Year: ethYear, Month: month, Day: day}
}

func isGregorianLeap(year int) bool {
	if year%400 == 0 {
		return true
	}
	if year%100 == 0 {
		return false
	}
	return year%4 == 0
}

// FormatYYYYMMDD returns a YYYY-MM-DD formatted Ethiopian date.
func (e EthiopianDate) FormatYYYYMMDD() string {
	return fmt.Sprintf("%04d-%02d-%02d", e.Year, e.Month, e.Day)
}
