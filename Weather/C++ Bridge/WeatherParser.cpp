//
//  WeatherParser.cpp
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

#include "WeatherParser.h"
#include <iostream>
#include <sstream>
#include <tao/json.hpp>
#include <tao/pegtl.hpp>
#include <tao/json/contrib/traits.hpp>
#include <map>

using namespace std;

WeatherParser::WeatherParser() {}

CityWeather WeatherParser::parseCurrentWeather(const string& jsonString, const string& cityName) {
    CityWeather result;
    result.cityName = cityName;
    memset(&result.current, 0, sizeof(WeatherC));
    
    try {
        cout << "Парсинг текущей погоды для города " << cityName << endl;
        
        tao::json::value v = tao::json::from_string(jsonString);
        
        strncpy(result.current.cityName, cityName.c_str(), sizeof(result.current.cityName) - 1);
        result.current.cityName[sizeof(result.current.cityName) - 1] = '\0';
        
        if (auto* main = v.find("main")) {
            if (auto* temp = main->find("temp")) {
                result.current.temperature = temp->as<double>();
            }
            if (auto* feels_like = main->find("feels_like")) {
                result.current.feelsLike = feels_like->as<double>();
            }
            if (auto* pressure = main->find("pressure")) {
                result.current.pressure = pressure->as<double>();
            }
            if (auto* humidity = main->find("humidity")) {
                result.current.humidity = humidity->as<double>();
            }
        }
        
        if (auto* visibility = v.find("visibility")) {
            result.current.visibility = visibility->as<double>();
        }

        if (auto* wind = v.find("wind")) {
            if (auto* speed = wind->find("speed")) {
                result.current.windSpeed = speed->as<double>();
            }
        }
        
        if (auto* clouds = v.find("clouds")) {
            if (auto* all = clouds->find("all")) {
                result.current.cloudiness = all->as<double>();
            }
        }
        
        if (auto* weather = v.find("weather")) {
            if (weather->is_array()) {
                auto& weather_array = weather->get_array();
                if (!weather_array.empty()) {
                    auto& first = weather_array[0];
                    
                    if (auto* description = first.find("description")) {
                        string desc = description->get_string();
                        strncpy(result.current.weatherDescription, desc.c_str(),
                               sizeof(result.current.weatherDescription) - 1);
                        result.current.weatherDescription[sizeof(result.current.weatherDescription) - 1] = '\0';
                    }
                    
                    if (auto* icon = first.find("icon")) {
                        string ic = icon->get_string();
                        strncpy(result.current.weatherIcon, ic.c_str(),
                               sizeof(result.current.weatherIcon) - 1);
                        result.current.weatherIcon[sizeof(result.current.weatherIcon) - 1] = '\0';
                    }
                }
            }
        }
        
        result.current.timestamp = static_cast<int>(time(nullptr));
        
        cout << "Текущая температура: " << result.current.temperature << "°C" << endl;
        cout << "================================================" << endl;
        
    } catch (const tao::pegtl::parse_error& e) {
        cout << "C++: Ошибка парсинга JSON: " << e.what() << endl;
    } catch (const std::exception& e) {
        cout << "C++: Ошибка: " << e.what() << endl;
    }
    
    return result;
}

CityWeather WeatherParser::parseOneCallAPI(const string& jsonString, const string& cityName) {
    CityWeather result;
    result.cityName = cityName;
    memset(&result.current, 0, sizeof(WeatherC));
    strncpy(result.current.cityName, cityName.c_str(), sizeof(result.current.cityName) - 1);
    result.current.cityName[sizeof(result.current.cityName) - 1] = '\0';
    
    result.forecast.clear();
    
    try {
        cout << "Парсинг прогноза для " << cityName << endl;
        cout << "JSON длина: " << jsonString.length() << " символов" << endl;
        
        tao::json::value v = tao::json::from_string(jsonString);
        
        if (auto* cod = v.find("cod")) {
            string codStr;
            if (cod->is_string()) {
                codStr = cod->get_string();
            } else {
                codStr = to_string(cod->as<int>());
            }
            
            if (codStr != "200") {
                cout << "Ошибка API: код " << codStr << endl;
                return result;
            }
            cout << "API ответ: успешно" << endl;
        }
        
        if (auto* list = v.find("list")) {
            if (list->is_array()) {
                auto& forecast_list = list->get_array();
                cout << "Найден блок 'list', всего записей: " << forecast_list.size() << endl;
                
                if (forecast_list.empty()) {
                    cout << "Нет данных прогноза" << endl;
                    return result;
                }
                
                result.hourly.clear();
                int hourlyIndex = 0;
                
                for (const auto& item : forecast_list) {
                    if (hourlyIndex >= 40) break;
                    
                    HourlyForecastC hourly;
                    memset(&hourly, 0, sizeof(HourlyForecastC));
                    
                    if (auto* dt = item.find("dt")) {
                        hourly.timestamp = static_cast<int>(dt->as<double>());
                    }
                    
                    if (auto* main = item.find("main")) {
                        if (auto* temp = main->find("temp")) {
                            hourly.temperature = temp->as<double>();
                        }
                        if (auto* feels_like = main->find("feels_like")) {
                            hourly.feelsLike = feels_like->as<double>();
                        }
                        if (auto* humidity = main->find("humidity")) {
                            hourly.humidity = humidity->as<double>();
                        }
                    }
                    
                    if (auto* wind = item.find("wind")) {
                        if (auto* speed = wind->find("speed")) {
                            hourly.windSpeed = speed->as<double>();
                        }
                    }
                    
                    if (auto* weather = item.find("weather")) {
                        if (weather->is_array()) {
                            auto& weather_array = weather->get_array();
                            if (!weather_array.empty()) {
                                auto& w = weather_array[0];
                                
                                if (auto* description = w.find("description")) {
                                    string desc = description->get_string();
                                    strncpy(hourly.weatherDescription, desc.c_str(),
                                           sizeof(hourly.weatherDescription) - 1);
                                    hourly.weatherDescription[sizeof(hourly.weatherDescription) - 1] = '\0';
                                }
                                
                                if (auto* icon = w.find("icon")) {
                                    string ic = icon->get_string();
                                    strncpy(hourly.weatherIcon, ic.c_str(),
                                           sizeof(hourly.weatherIcon) - 1);
                                    hourly.weatherIcon[sizeof(hourly.weatherIcon) - 1] = '\0';
                                }
                            }
                        }
                    }
                    
                    result.hourly.push_back(hourly);
                    hourlyIndex++;
                }
                
                cout << "Заполнено почасовых записей: " << result.hourly.size() << endl;
                
                auto& first = forecast_list[0];
                
                if (auto* main = first.find("main")) {
                    if (auto* temp = main->find("temp")) {
                        result.current.temperature = temp->as<double>();
                    }
                    if (auto* feels_like = main->find("feels_like")) {
                        result.current.feelsLike = feels_like->as<double>();
                    }
                    if (auto* pressure = main->find("pressure")) {
                        result.current.pressure = pressure->as<double>();
                    }
                    if (auto* humidity = main->find("humidity")) {
                        result.current.humidity = humidity->as<double>();
                    }
                }
                
                if (auto* visibility = first.find("visibility")) {
                    result.current.visibility = visibility->as<double>();
                }
                
                if (auto* wind = first.find("wind")) {
                    if (auto* speed = wind->find("speed")) {
                        result.current.windSpeed = speed->as<double>();
                    }
                }
                
                if (auto* clouds = first.find("clouds")) {
                    if (auto* all = clouds->find("all")) {
                        result.current.cloudiness = all->as<double>();
                    }
                }

                if (auto* weather = first.find("weather")) {
                    if (weather->is_array()) {
                        auto& weather_array = weather->get_array();
                        if (!weather_array.empty()) {
                            auto& w = weather_array[0];
                            
                            if (auto* description = w.find("description")) {
                                string desc = description->get_string();
                                strncpy(result.current.weatherDescription, desc.c_str(),
                                       sizeof(result.current.weatherDescription) - 1);
                                result.current.weatherDescription[sizeof(result.current.weatherDescription) - 1] = '\0';
                            }
                            
                            if (auto* icon = w.find("icon")) {
                                string ic = icon->get_string();
                                strncpy(result.current.weatherIcon, ic.c_str(),
                                       sizeof(result.current.weatherIcon) - 1);
                                result.current.weatherIcon[sizeof(result.current.weatherIcon) - 1] = '\0';
                            }
                        }
                    }
                }
                
                if (auto* dt = first.find("dt")) {
                    result.current.timestamp = static_cast<int>(dt->as<double>());
                }
                
                cout << "Текущая температура: " << result.current.temperature << "°C" << endl;
                
                map<int, vector<tao::json::value>> days;
                
                for (const auto& item : forecast_list) {
                    if (auto* dt = item.find("dt")) {
                        int timestamp = static_cast<int>(dt->as<double>());
                        int day = timestamp / 86400;
                        days[day].push_back(item);
                    }
                }
                
                cout << "Уникальных дней в прогнозе: " << days.size() << endl;
                
                int dayCount = 0;
                for (const auto& [day, items] : days) {
                    if (dayCount >= 3) break;
                    
                    DailyForecastC forecast;
                    memset(&forecast, 0, sizeof(DailyForecastC));
                    
                    strncpy(forecast.cityName, cityName.c_str(), sizeof(forecast.cityName) - 1);
                    forecast.cityName[sizeof(forecast.cityName) - 1] = '\0';
                    
                    if (auto* dt = items[0].find("dt")) {
                        forecast.timestamp = static_cast<int>(dt->as<double>());
                    }
                    
                    double dayTempSum = 0;
                    double nightTempSum = 0;
                    int dayCountTemp = 0;
                    int nightCountTemp = 0;
                    
                    for (const auto& item : items) {
                        if (auto* main = item.find("main")) {
                            if (auto* temp = main->find("temp")) {
                                if (auto* dt_txt = item.find("dt_txt")) {
                                    string timeStr = dt_txt->get_string();
                                    int hour = 0;
                                    if (timeStr.length() >= 13) {
                                        hour = stoi(timeStr.substr(11, 2));
                                    }
                                    
                                    if (hour >= 6 && hour <= 18) {
                                        dayTempSum += temp->as<double>();
                                        dayCountTemp++;
                                    } else {
                                        nightTempSum += temp->as<double>();
                                        nightCountTemp++;
                                    }
                                }
                            }
                        }
                    }
                    
                    forecast.temperatureDay = (dayCountTemp > 0) ? dayTempSum / dayCountTemp : 0;
                    forecast.temperatureNight = (nightCountTemp > 0) ? nightTempSum / nightCountTemp : 0;
                    
                    if (auto* main = items[0].find("main")) {
                        if (auto* pressure = main->find("pressure")) {
                            forecast.pressure = pressure->as<double>();
                        }
                        if (auto* humidity = main->find("humidity")) {
                            forecast.humidity = humidity->as<double>();
                        }
                    }
                    
                    if (auto* visibility = items[0].find("visibility")) {
                        forecast.visibility = visibility->as<double>();
                    }
                    
                    if (auto* clouds = items[0].find("clouds")) {
                        if (auto* all = clouds->find("all")) {
                            forecast.cloudiness = all->as<double>();
                        }
                    }
                    
                    if (auto* weather = items[0].find("weather")) {
                        if (weather->is_array()) {
                            auto& weather_array = weather->get_array();
                            if (!weather_array.empty()) {
                                auto& w = weather_array[0];
                                
                                if (auto* description = w.find("description")) {
                                    string desc = description->get_string();
                                    strncpy(forecast.weatherDescription, desc.c_str(),
                                           sizeof(forecast.weatherDescription) - 1);
                                    forecast.weatherDescription[sizeof(forecast.weatherDescription) - 1] = '\0';
                                }
                                
                                if (auto* icon = w.find("icon")) {
                                    string ic = icon->get_string();
                                    if (ic.length() > 0 && ic.back() == 'n') {
                                        ic.back() = 'd';
                                    }
                                    strncpy(forecast.weatherIcon, ic.c_str(),
                                           sizeof(forecast.weatherIcon) - 1);
                                    forecast.weatherIcon[sizeof(forecast.weatherIcon) - 1] = '\0';
                                }
                            }
                        }
                    }
                    
                    result.forecast.push_back(forecast);
                    cout << "    День " << dayCount + 1 << ": "
                         << forecast.temperatureDay << "°C / "
                         << forecast.temperatureNight << "°C, "
                         << forecast.weatherDescription << endl;
                    
                    dayCount++;
                }
                
                cout << "Всего распарсено дней: " << result.forecast.size() << endl;
            }
        } else {
            cout << "ОШИБКА: Не найден блок 'list' в JSON!" << endl;
        }
        
        cout << "================================================" << endl;
        
    } catch (const tao::pegtl::parse_error& e) {
        cout << "C++: Ошибка парсинга JSON: " << e.what() << endl;
    } catch (const std::exception& e) {
        cout << "C++: Ошибка: " << e.what() << endl;
    } catch (...) {
        cout << "C++: Неизвестная ошибка при парсинге" << endl;
    }
    
    return result;
}
