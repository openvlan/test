namespace :seed do
  desc "seed a clean db"
  task init: :environment do

    miami_address = {
      "gps_coordinates"=>"POINT ( -80.32430203931557 25.792858888563703)",
      "street_1"=>"8651 NW 13th Terrace",
      "street_2"=>nil,
      "zip_code"=>"33127",
      "city"=>"Doral",
      "state"=>"Florida",
      "country"=>"United States",
      "contact_name"=>"Contact",
      "contact_cellphone"=>"13054704510",
      "contact_email"=>"as@as.com",
      "telephone"=>"13054704510",
      "notes"=>"",
      "formatted_address"=>"8651 NW 13th Terrace, Doral, FL 33126, USA"
    }

    new_york_address = {
      "gps_coordinates"=>"POINT ( -73.7228087452293 40.67361521637831)",
      "street_1"=>"77 Green Acres Rd S",
      "street_2"=>nil,
      "zip_code"=>"11581",
      "city"=>"Valley Stream",
      "state"=>"New York",
      "country"=>"United States",
      "contact_name"=>"Contact",
      "contact_cellphone"=>"15162934520",
      "contact_email"=>"as@as.com",
      "telephone"=>"15162934520",
      "notes"=>"",
      "formatted_address"=>"77 Green Acres Rd S, Valley Stream, NY 11581, USA"
    }

    drivers = [
      {
        "shipper": {
          "id": "91b4ffa8-daad-4dda-a428-8c5c7e8d4ce0",
          "status": "Active",
          "email": "sfl.code@gmail.com",
          "first_name": "Santiago",
          "last_name": "Fernandez",
          "birth_date": "1986-12-01",
          "phone_num": "+541136430388",
          "license_attributes": {
            "id": 9,
            "number": "F4532757967",
            "state": "Florida",
            "expiration_date": "2023-05-11T09:49:01.000-04:00",
            "photos": [
              {
                "id": 26,
                "url": "https://files-demo-tikoglobal-com.s3.us-east-2.amazonaws.com/logistics-api/qbLi9WDJMphdYtRvT5JMqbJg?response-content-disposition=inline%3B%20filename%3D%22079D9549-5FE1-4B04-9693-E826A86CA3D6.jpg%22%3B%20filename%2A%3DUTF-8%27%27079D9549-5FE1-4B04-9693-E826A86CA3D6.jpg&response-content-type=image%2Fjpeg&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUHFFPUMRDHKBJZPN%2F20211115%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20211115T123250Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=0b90a9a7d553875ff07e5f016d7ac9e94e8b4d875b917f0ed0d32d63f0b0d814",
                "position": 0,
                "signed_id": "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBOZz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--77bc5118928ecd8efa74576e3885b45ff4bf04cd"
              },
              {
                "id": 27,
                "url": "https://files-demo-tikoglobal-com.s3.us-east-2.amazonaws.com/logistics-api/qkGjLZdFM59Y483LDms37EVA?response-content-disposition=inline%3B%20filename%3D%22A7AD5051-525F-43B8-9568-45EF3C210AA6.jpg%22%3B%20filename%2A%3DUTF-8%27%27A7AD5051-525F-43B8-9568-45EF3C210AA6.jpg&response-content-type=image%2Fjpeg&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUHFFPUMRDHKBJZPN%2F20211115%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20211115T123250Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=8f113956620d24b73eab4b10dfe8e415566eefebb50119e7a617639a2f8e3bc0",
                "position": 1,
                "signed_id": "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBOdz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--9fbca232ed80fd5db16203aa46e8373fa5e39ab6"
              }
            ]
          },
          "working_hours": {
            "weekend": [
              "saturday",
              "sunday"
            ],
            "workweek": [
              "monday",
              "tuesday",
              "wednesday",
              "thursday",
              "friday"
            ],
            "to_weekend": 23,
            "to_workweek": 23,
            "from_weekend": 0,
            "from_workweek": 0
          },
          "vehicle_attributes": {
            "id": "0f561363-e70c-47cf-b621-bb8086d081ab",
            "truck_type": "dry_van",
            "year": 2008,
            "make": "Mercedes Benz",
            "model": "Van",
            "color": "Black",
            "license_plate": "XTR 365",
            "gross_vehicle_weight_rating": 2500,
            "insurance_provider": "Geico ",
            "has_liftgate": false,
            "has_forklift": false,
            "photos": [
              {
                "id": 40,
                "url": "https://files-demo-tikoglobal-com.s3.us-east-2.amazonaws.com/logistics-api/QoYVEUFW7QpQHf5SrPf5onBK?response-content-disposition=inline%3B%20filename%3D%22download%20%252811%2529.jpeg%22%3B%20filename%2A%3DUTF-8%27%27download%2520%252811%2529.jpeg&response-content-type=image%2Fjpeg&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUHFFPUMRDHKBJZPN%2F20211115%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20211115T123250Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=a54ad0ed0f8bd6644cb72b1cb1dc41304e754367452e6ae49f87f6927c9cd5c4",
                "position": 0,
                "signed_id": "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBUZz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--53ee3ba4e6e58695566cfd236ce3995b134f9202"
              },
              {
                "id": 41,
                "url": "https://files-demo-tikoglobal-com.s3.us-east-2.amazonaws.com/logistics-api/ykNDJ6KeHY5y3gqHugJY8mni?response-content-disposition=inline%3B%20filename%3D%22rn_image_picker_lib_temp_17924e60-ff5a-4755-9d7e-0ba50b5c68c8.jpg%22%3B%20filename%2A%3DUTF-8%27%27rn_image_picker_lib_temp_17924e60-ff5a-4755-9d7e-0ba50b5c68c8.jpg&response-content-type=image%2Fjpeg&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUHFFPUMRDHKBJZPN%2F20211115%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20211115T123250Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=53e4d77900dfae394badea61e1bfd2c6f7911b8ca7c50276e53b4e683a420eab",
                "position": 0,
                "signed_id": "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBVQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--c8c5d0241cd4fb333518bf1313591feb1ded9ebe"
              }
            ]
          },
          "company_attributes": {
            "id": 9,
            "name": "Santiago Fernandez Driving LLC",
            "ein": 123453789,
            "max_distance_from_base": "15000.0",
            "usdot": 123456789,
            "mc_number": 1234567860,
            "mc_number_type": "MC",
            "sacs_number": "1234537890",
            "address_attributes": {
              "id": "08cba93f-6067-44f7-9d68-908f9e6cdcfc",
              "street_1": "2395 NW 97th St",
              "street_2": "",
              "zip_code": "",
              "city": "Miami",
              "state": "Florida",
              "country": "Argentina",
              "notes": "",
              "gps_coordinates": nil,
              "formatted_address": "2395 NW 97th St, Miami, FL 33147",
              "_destroy": false
            }
          },
          "provided_services": [
            "ltl"
          ],
          "code": 17
        }
      },
    {
      "shipper": {
        "id": "b06c6549-88ef-411e-836d-956687212d43",
        "status": "Active",
        "email": "numa.leone+4@greencodesoftware.com",
        "first_name": "Oliver",
        "last_name": "Wilson",
        "birth_date": "1980-06-01",
        "phone_num": "+541153740766",
        "license_attributes": {
          "id": 8,
          "number": "L34534677",
          "state": "Florida ",
          "expiration_date": "2030-06-30T09:26:34.829-04:00",
          "photos": [
            {
              "id": 24,
              "url": "https://files-demo-tikoglobal-com.s3.us-east-2.amazonaws.com/logistics-api/3bxvEfLUMLQhY94m8nYmMJ9p?response-content-disposition=inline%3B%20filename%3D%22rn_image_picker_lib_temp_4e2ddc89-5641-45de-a19e-2dc6e30575bf.jpg%22%3B%20filename%2A%3DUTF-8%27%27rn_image_picker_lib_temp_4e2ddc89-5641-45de-a19e-2dc6e30575bf.jpg&response-content-type=image%2Fjpeg&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUHFFPUMRDHKBJZPN%2F20211115%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20211115T123316Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=bd29cfcf8d4e919f77ee7c7d67be867ac9d081f1017e55c85549f2f469e42482",
              "position": 0,
              "signed_id": "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBNdz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--dbe121f0889feef3263b1f1439608f4f8f2570fd"
            },
            {
              "id": 23,
              "url": "https://files-demo-tikoglobal-com.s3.us-east-2.amazonaws.com/logistics-api/bKpFA8zKHeQj5begmn7XaqzG?response-content-disposition=inline%3B%20filename%3D%22rn_image_picker_lib_temp_7026169f-ce3b-42c8-a429-0afadfb3a132.jpg%22%3B%20filename%2A%3DUTF-8%27%27rn_image_picker_lib_temp_7026169f-ce3b-42c8-a429-0afadfb3a132.jpg&response-content-type=image%2Fjpeg&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUHFFPUMRDHKBJZPN%2F20211115%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20211115T123316Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=049e4afb61f97156ffca0b4f72d9775d5f97ed0b829a2c08bf54522af9b6f57f",
              "position": 1,
              "signed_id": "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBOQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--a69381bb2328ab814e8879be44d3ffc2b3ce5f6f"
            }
          ]
        },
        "working_hours": {
          "weekend": [],
          "workweek": [
            "monday",
            "tuesday",
            "wednesday",
            "thursday",
            "friday"
          ],
          "to_weekend": 19,
          "to_workweek": 19,
          "from_weekend": 7,
          "from_workweek": 7
        },
        "vehicle_attributes": {
          "id": "3e63713d-3856-4d02-bf28-76c116c48905",
          "truck_type": "dry_van",
          "year": 2020,
          "make": "Pedigree",
          "model": "Freightliner Evolution",
          "color": "Green",
          "license_plate": "AYR 155",
          "gross_vehicle_weight_rating": 50000,
          "insurance_provider": "AAA",
          "has_liftgate": true,
          "has_forklift": false,
          "photos": [
            {
              "id": 22,
              "url": "https://files-demo-tikoglobal-com.s3.us-east-2.amazonaws.com/logistics-api/TimzkgPc1usjaUELgFnKEheW?response-content-disposition=inline%3B%20filename%3D%22rn_image_picker_lib_temp_5f301d20-eddc-4930-adc6-c2812d3aba6f.jpg%22%3B%20filename%2A%3DUTF-8%27%27rn_image_picker_lib_temp_5f301d20-eddc-4930-adc6-c2812d3aba6f.jpg&response-content-type=image%2Fjpeg&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUHFFPUMRDHKBJZPN%2F20211115%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20211115T123316Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=160d89b304baa0e07e74a3735a7506f18b166aae3adebe8fafa9649e505f528b",
              "position": 0,
              "signed_id": "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBOUT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--beb939acbae5a2040688f27e4ca0c0b9cb4b40e8"
            }
          ]
        },
        "company_attributes": {
          "id": 8,
          "name": "Timeless Trucking",
          "ein": 123456789,
          "max_distance_from_base": "1000.0",
          "usdot": nil,
          "mc_number": nil,
          "mc_number_type": "no",
          "sacs_number": "",
          "address_attributes": {
            "id": "2b68ec3b-10e1-474a-83cb-dbefc7c388ac",
            "street_1": "2401 NW 69th St",
            "street_2": "",
            "zip_code": "33147",
            "city": "Miami",
            "state": "Florida",
            "country": "United States",
            "notes": "",
            "gps_coordinates": nil,
            "formatted_address": "2401 NW 69th St, Miami, FL 33147, USA",
            "_destroy": false
          }
        },
        "provided_services": [
          "ltl"
        ],
        "code": 21
      }
    },
    {
      "shipper": {
        "id": "5f324764-bae0-408d-a3b9-6230ebaa84f2",
        "status": "Active",
        "email": "numa.leone+7@greencodesoftware.com",
        "first_name": "John",
        "last_name": "Dow",
        "birth_date": "1972-09-30",
        "phone_num": "+18605791386",
        "license_attributes": {
          "id": 15,
          "number": "aaa-000",
          "state": "AL",
          "expiration_date": "2057-09-30T16:26:20.000-04:00",
          "photos": [
            {
              "id": 48,
              "url": "https://files-demo-tikoglobal-com.s3.us-east-2.amazonaws.com/logistics-api/6S7yXSLMgNuQD9wCXydU8rY6?response-content-disposition=inline%3B%20filename%3D%227521D592-5080-4980-B753-497BE8E13EDC.jpg%22%3B%20filename%2A%3DUTF-8%27%277521D592-5080-4980-B753-497BE8E13EDC.jpg&response-content-type=image%2Fjpeg&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUHFFPUMRDHKBJZPN%2F20211115%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20211115T123333Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=3be71fe10cd32c49505e96f9cf30692c345efb5325c8c99e789dea75d44810d1",
              "position": 0,
              "signed_id": "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBWdz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--9663c374734ee0841b52945e96dbbd129a1af25b"
            },
            {
              "id": 49,
              "url": "https://files-demo-tikoglobal-com.s3.us-east-2.amazonaws.com/logistics-api/zBEPsXq3YfTrowMu3Jd6gctD?response-content-disposition=inline%3B%20filename%3D%22DD590234-80C6-46B5-8C25-BCFB257B1B65.jpg%22%3B%20filename%2A%3DUTF-8%27%27DD590234-80C6-46B5-8C25-BCFB257B1B65.jpg&response-content-type=image%2Fjpeg&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUHFFPUMRDHKBJZPN%2F20211115%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20211115T123333Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=c5165374d924c84deff37343ac6a3943d9250bc66e27d028191856bd787110b9",
              "position": 0,
              "signed_id": "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBXQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--302f9620d01f1ae1410b26301a7b0d8bc8705d18"
            }
          ]
        },
        "working_hours": {},
        "vehicle_attributes": {
          "id": "8ed3cb8c-ff53-4139-bfcb-7ce9dbe29de7",
          "truck_type": "refrigerated",
          "year": 2021,
          "make": "Renault",
          "model": "Fire",
          "color": "Black",
          "license_plate": "aaa-111",
          "gross_vehicle_weight_rating": 1235008,
          "insurance_provider": "Renault ",
          "has_liftgate": true,
          "has_forklift": true,
          "photos": [
            {
              "id": 47,
              "url": "https://files-demo-tikoglobal-com.s3.us-east-2.amazonaws.com/logistics-api/eniTivZpiZ3Ko7H9WFrJU6uK?response-content-disposition=inline%3B%20filename%3D%225027CC74-74A0-472F-8E7D-F4E944646156.jpg%22%3B%20filename%2A%3DUTF-8%27%275027CC74-74A0-472F-8E7D-F4E944646156.jpg&response-content-type=image%2Fjpeg&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUHFFPUMRDHKBJZPN%2F20211115%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20211115T123333Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=f6070efc86535c7d65919f1b85a7f7f17f527457e5c978fcb0346dea0c7777c9",
              "position": 0,
              "signed_id": "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBXUT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--0a4746a389ffdf5d0cbf3e9beeecf378eec4bbfa"
            }
          ]
        },
        "company_attributes": {
          "id": 15,
          "name": "",
          "ein": nil,
          "max_distance_from_base": nil,
          "usdot": nil,
          "mc_number": 123,
          "mc_number_type": "FF",
          "sacs_number": "",
          "address_attributes": {
            "id": "1befc47e-7f86-43d8-bded-d3959b90c661",
            "street_1": "1000 Central Park S",
            "street_2": "",
            "zip_code": "10019",
            "city": "New York",
            "state": "New York",
            "country": "United States",
            "notes": "",
            "gps_coordinates": nil,
            "formatted_address": "1000 Central Park S, New York, NY 10019, USA",
            "_destroy": false
          }
        },
        "provided_services": [
          "drayage",
          "ltl"
        ],
        "code": 49
      }
    }
    ]

    drivers.map { |driver| driver[:shipper] }.each_with_index do | driver, index |
      p '-' * 20
      p "(#{index}) #{driver[:first_name]} #{driver[:last_name]}"

      company_attr = driver[:company_attributes]
      company = Company.find_or_create_by!(name: company_attr[:name]) do |new_company|
        new_company.max_distance_from_base = company_attr[:max_distance_from_base]
        new_company.mc_number = company_attr[:mc_number]
        new_company.mc_number_type = company_attr[:mc_number_type]
        new_company.ein = company_attr[:ein]
        new_company.usdot = company_attr[:usdot]
        new_company.sacs_number = company_attr[:sacs_number]
        new_company.build_address(index % 2 == 0 ? miami_address : new_york_address)
      end

      shipper = Shipper.find_or_create_by!(first_name: driver[:first_name], last_name: driver[:last_name]) do |new_driver|
        user = User.create_driver({
                                            first_name: driver[:first_name],
                                            last_name: driver[:last_name],
                                            active: true,
                                            email: driver[:email],
                                            password: 'password',
                                            phone: driver[:phone]
                                          })
        new_driver.first_name = driver[:first_name]
        new_driver.last_name = driver[:last_name]
        new_driver.birth_date = driver[:birth_date]
        new_driver.provided_services = driver[:provided_services]
        new_driver.user_id = user.id
        new_driver.working_hours = driver[:working_hours]

        new_driver.build_license(driver[:license_attributes].except(:id, :photos))
        new_driver.build_vehicle(driver[:vehicle_attributes].except(:id, :photos))
        new_driver.company_id = company.id
      end
      shipper.active!
    end

    License.all.each do |license|
      license.photos.destroy_all
      license.photos.attach(io: File.open(File.join(Rails.root, 'lib/tasks/images/licenses/florida_license_2.jpeg')), filename: 'florida_license_2.jpeg')
      license.photos.attach(io: File.open(File.join(Rails.root, 'lib/tasks/images/licenses/florida_license_2.jpeg')), filename: 'florida_license_2.jpeg')
      license.save!
    end


  end
end
