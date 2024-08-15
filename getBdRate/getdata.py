#!/usr/bin/python3
import os
import re
# import matplotlib.pyplot as plt
# import numpy as np
# 存储所有MVDx和MVDy的值和数量

percentage = {}
# value_counts_y = {}
total_samples = 0
valid_samples = 0
# 统计MVD绝对值小于2的样本数量
folder_num = 0
x_values_folder = {}
sorted_distribution_x_folder = {}
# y_values_folder = {}
# sorted_distribution_y_folder = {}
# 文件夹列表
# folders = ['RaceHorsesC_22', 'RaceHorsesC_27', 'RaceHorsesC_32', 'RaceHorsesC_37']
# folders = ['BasketballPass_22', 'BasketballPass_27', 'BasketballPass_32', 'BasketballPass_37']
# folders = ['RaceHorses_22', 'RaceHorses_27', 'RaceHorses_32', 'RaceHorses_37']
# folders = ['BasketballDrill_22', 'BasketballDrill_27', 'BasketballDrill_32', 'BasketballDrill_37']
# folders = ['BlowingBubbles_22', 'BlowingBubbles_27', 'BlowingBubbles_32', 'BlowingBubbles_37']
# folders = ['BQSquare_22', 'BQSquare_27', 'BQSquare_32', 'BQSquare_37']


# # LDP
folder_lists = [
    # D
    # ['BasketballPass_22', 'BasketballPass_27', 'BasketballPass_32', 'BasketballPass_37'],
    # ['BlowingBubbles_22', 'BlowingBubbles_27', 'BlowingBubbles_32', 'BlowingBubbles_37'],
    # ['BQSquare_22', 'BQSquare_27', 'BQSquare_32', 'BQSquare_37'],
    # ['RaceHorses_22', 'RaceHorses_27', 'RaceHorses_32', 'RaceHorses_37'],
    # # C
    ['BasketballDrill_22', 'BasketballDrill_27', 'BasketballDrill_32', 'BasketballDrill_37'],
    ['BQMall_22', 'BQMall_27', 'BQMall_32', 'BQMall_37'],
    ['PartyScene_22', 'PartyScene_27', 'PartyScene_32', 'PartyScene_37'],
    ['RaceHorsesC_22', 'RaceHorsesC_27', 'RaceHorsesC_32', 'RaceHorsesC_37'],
    # # E
    # ['FourPeople_22', 'FourPeople_27', 'FourPeople_32', 'FourPeople_37'],
    # ['Johnny_22', 'Johnny_27', 'Johnny_32', 'Johnny_37'],
    # ['KristenAndSara_22', 'KristenAndSara_27', 'KristenAndSara_32', 'KristenAndSara_37'],
    # screen content
    # ['ArenaOfValor_22', 'ArenaOfValor_27', 'ArenaOfValor_32', 'ArenaOfValor_37'],
    # ['SlideEditing_22', 'SlideEditing_27', 'SlideEditing_32', 'SlideEditing_37'],
    # ['SlideShow_22', 'SlideShow_27', 'SlideShow_32', 'SlideShow_37'],
    # ['BasketballDrillText_22', 'BasketballDrillText_27', 'BasketballDrillText_32', 'BasketballDrillText_37'],
    # B
    # ['MarketPlace_22', 'MarketPlace_27', 'MarketPlace_32', 'MarketPlace_37'],
    # ['BasketballDrive_22', 'BasketballDrive_27', 'BasketballDrive_32', 'BasketballDrive_37'],
    # ['BQTerrace_22', 'BQTerrace_27', 'BQTerrace_32', 'BQTerrace_37'],
    # ['Cactus_22', 'Cactus_27', 'Cactus_32', 'Cactus_37'],
    # ['RitualDance_22', 'RitualDance_27', 'RitualDance_32', 'RitualDance_37'],
    # # A1
    # ['FoodMarket4_22', 'FoodMarket4_27', 'FoodMarket4_32', 'FoodMarket4_37'],
    # ['Tango2_22', 'Tango2_27', 'Tango2_32', 'Tango2_37'],
    # ['Campfire_22', 'Campfire_27', 'Campfire_32', 'Campfire_37'],
    # # A2
    # ['ParkRunning3_22', 'ParkRunning3_27', 'ParkRunning3_32', 'ParkRunning3_37'],
    # ['CatRobot_22', 'CatRobot_27', 'CatRobot_32', 'CatRobot_37'],
    # ['DaylightRoad2_22', 'DaylightRoad2_27', 'DaylightRoad2_32', 'DaylightRoad2_37'],
]


# Create variables to store the extracted percentage values
iter_zero_percentage = 0.0
iter_one_percentage = 0.0
iter_two_percentage = 0.0
iter_three_percentage = 0.0
iter_four_percentage = 0.0




# 循环处理每个文件夹列表
for folder_list in folder_lists:
    folder_num += 1
    BME_value = 0
    opticalME_value = 0
    for folder in folder_list:
        folder_path = os.path.join(os.getcwd(), folder)  # 文件夹路径

        # 循环处理文件夹中的VTM.log文件
        for file_name in os.listdir(folder_path):
            if file_name.endswith('.log'):
                file_path = os.path.join(folder_path, file_name)

                # 读取日志文件
                print(file_path)
                with open(file_path, 'r') as file:
                    log_data = file.read()

                # 使用正则表达式匹配值
                # Regular expression pattern to match and extract percentage values
                pattern = r'iter_(\w+)_num\s*:\s*\d+\s*\(\s*([\d.]+) %\)'
                matches = re.findall(pattern, log_data)

                # Create a dictionary to store the extracted percentage values
                percentage_dict = {match[0]: float(match[1]) for match in matches}

                # Print the extracted percentage values
                # Update the variables based on the extracted values
                for key, value in matches:
                    if key == "zero":
                        iter_zero_percentage += float(value)
                    elif key == "one":
                        iter_one_percentage += float(value)
                    elif key == "two":
                        iter_two_percentage += float(value)
                    elif key == "three":
                        iter_three_percentage += float(value)
                    elif key == "four":
                        iter_four_percentage += float(value)
sum = iter_zero_percentage + iter_one_percentage + iter_two_percentage + iter_three_percentage + iter_four_percentage
iter_zero_percentage  = iter_zero_percentage  / sum
iter_one_percentage   = iter_one_percentage   / sum
iter_two_percentage   = iter_two_percentage   / sum
iter_three_percentage = iter_three_percentage / sum
iter_four_percentage  = iter_four_percentage  / sum
print(f"iter_zero_percentage: {iter_zero_percentage}")
print(f"iter_one_percentage: {iter_one_percentage}")
print(f"iter_two_percentage: {iter_two_percentage}")
print(f"iter_three_percentage: {iter_three_percentage}")
print(f"iter_four_percentage: {iter_four_percentage}")

